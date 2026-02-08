{ withSystem, ... }: {

  flake.modules.nixos.hardware-chipsailing-fingerprint = { config, pkgs, ... } : {

    services.fprintd.enable = true;

    environment.systemPackages = with pkgs; [
      nss
    ];
  };

  flake.overlays.chipsailing = final: prev:
    withSystem prev.stdenv.hostPlatform.system (

      # perSystem parameters. Note that perSystem does not use `final` or `prev`.
      { config, ... }: {

        libfprint = prev.libfprint.overrideAttrs (oldAttrs: {
          version = "git";
          src = final.fetchFromGitHub {
            owner = "deftdawg";
            repo = "libfprint-CS9711";
            rev = "56bf490f8ea2ab9049f410b9dfe78b33d59fd2c4";
            sha256 = "sha256-PVr/Mi3m0P1bojVYriubmpA8QC5oayV5RtHbyXyHPC0=";
          };
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
            final.opencv
            final.cmake
            final.doctest
          ];
        });
      });
}
