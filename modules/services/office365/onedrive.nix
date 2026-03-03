{ inputs, ... } : {
  flake.modules.nixos.services-office365 = { config, pkgs, ... }: {
    services.onedrive.enable = false;
  };
}


