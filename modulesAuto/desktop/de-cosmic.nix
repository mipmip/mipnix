{pkgs,lib,config, ...}:{
  config = lib.mkIf config.nixos.full.enable {
    services.desktopManager.cosmic.enable = true;
  };
}
