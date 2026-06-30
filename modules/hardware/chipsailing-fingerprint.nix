{ withSystem, ... }: {

  flake.modules.nixos.hardware-chipsailing-fingerprint = { config, pkgs, ... } : {

    services.fprintd.enable = true;

    # The CS9711 dongle does not survive USB runtime power management: after ~2s
    # of inactivity the kernel autosuspends it, and the next wake (e.g. a verify
    # at screenlock) makes it disconnect/reconnect on the bus, after which
    # fprintd reports "device was disconnected, aborting" and authentication
    # fails until the daemon is restarted. Disabling autosuspend for this
    # specific device (vendor 2541, product 0236) keeps it powered and stable.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2541", ATTR{idProduct}=="0236", TEST=="power/control", ATTR{power/control}="on"
    '';

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
