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
      });
}
