{ config, lib, ... }:

let
  cfg = config.desktopConf.alacritty;
in
  {

  options.desktopConf.alacritty = {
    enable = lib.mkEnableOption "Enable alacritty";
  };

  config = lib.mkIf cfg.enable {

    programs.alacritty = {
      enable = true;

      settings = {
        window.padding = {
          x = 10;
          y = 10;
        };
        font.normal = {
          family = "DejaVu Sans Mono";
          style = "Regular";
        };
      };
    };
  };
}
