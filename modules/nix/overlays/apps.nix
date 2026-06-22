{ withSystem, inputs, ... }: {

  flake.overlays.apps = final: prev:
    withSystem prev.stdenv.hostPlatform.system (

      # perSystem parameters. Note that perSystem does not use `final` or `prev`.
      { config, ... }:
      let
        # Quarto pinned to the nixpkgs 25.11 release (1.7.34) — temporary
        # workaround for a 1.9.x (26.05) regression; downgrade is the fastest
        # fix. To revert: base `quarto` below on `prev` instead of `pkgs2511`
        # (returns to the default 26.05 Quarto) once 1.9.x works again.
        pkgs2511 = import inputs.nixpkgs-2511 {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      in
      {

        #        bambu-studio = prev.bambu-studio.overrideAttrs (oldAttrs: {
        #          version = "01.00.01.50";
        #          src = prev.fetchFromGitHub {
        #            owner = "bambulab";
        #            repo = "BambuStudio";
        #            rev = "v01.00.01.50";
        #            hash = "sha256-7mkrPl2CQSfc1lRjl1ilwxdYcK5iRU//QGKmdCicK30=";
        #          };
        #        });

        #sc-im = prev.sc-im.overrideAttrs (old: {
        #  hardeningDisable = [ "fortify" ];
        #  env = (old.env or {}) // {
        #    NIX_CFLAGS_COMPILE = toString (old.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=incompatible-pointer-types";
        #  };
        #  src = prev.fetchFromGitHub {
        #    version = "0.8.5";
        #    owner = "mipmip";
        #    repo = "sc-im";
        #    rev = "pimsMain";
        #    hash = "sha256-8KwGDEmr182ippdoeNVvNMFN6+iJu83xkX7xMbI5/No=";
        #  };
        #});

        quarto = pkgs2511.quarto.override {
          extraRPackages = [
            pkgs2511.rPackages.reticulate
          ];
          extraPythonPackages = ps: with ps; [
            plotly
            numpy
            pandas
            matplotlib
            tabulate
          ];
        };

        # Karere (WhatsApp client) is a WebKitGTK app whose internal sandbox
        # (bwrap + xdg-dbus-proxy) fails to launch on this NixOS setup with:
        #   "Failed to fully launch dbus-proxy: Child process exited with code 1"
        # Disabling WebKit's process sandbox is the standard workaround. We bake
        # the env var into both the CLI wrapper and the .desktop Exec line so it
        # also applies when launched from the app launcher — not just `karere`
        # from a shell. Trade-off: this turns off WebKit subprocess isolation;
        # acceptable for a trusted personal WhatsApp client.
        karere = prev.karere.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/karere \
              --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS 1

            for desktop in $out/share/applications/*.desktop; do
              substituteInPlace "$desktop" \
                --replace-quiet 'Exec=karere' 'Exec=env WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 karere'
            done
          '';
        });
      });
}
