{ inputs, ... } : {
  flake.modules.nixos.framework-fingerprint = { config, pkgs, ... }: {

    # Install the driver
    services.fprintd.enable = true;

    # If simply enabling fprintd is not enough, try enabling fprintd.tod...
    services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
    #security.pam.services.login.fprintAuth = false;
  };
}

