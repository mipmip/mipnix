{ inputs, ... } : {
  flake.modules.nixos.framework-fingerprint = { config, pkgs, ... }: {

    services.fprintd.enable = true;
  };
}
