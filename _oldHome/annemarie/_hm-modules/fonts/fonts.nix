{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.fonts;
in
  {

  options.desktopConf.fonts = {
    enable = lib.mkEnableOption "Enable freedesktop";
  };

  config = lib.mkIf cfg.enable {

    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];

  };
}
