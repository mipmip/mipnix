{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.kitty;
in
  {

  options.desktopConf.kitty = {
    enable = lib.mkEnableOption "Enable firefox";
  };

  config = lib.mkIf cfg.enable {

    programs.kitty = {
      enable = true;
      extraConfig = ''
      '';
      font = {
        name = "DejaVu Sans Mono";
      };
      settings = {
        #font_family = "FiraCode Nerd Font";
        #font_family = "Liberation Mono";
        #font_family = "DejaVu Sans Mono";
        cursor = "#cccccc";
        font_size = "12";
        #bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        confirm_os_window_close = "0";
        window_border_width = 0;
        #wayland_titlebar_color = "background";
        wayland_titlebar_color = "system";
        window_padding_width = 10;

        #hide_window_decorations = "yes";


        enable_audio_bell = false;
        scrollback_lines = -1;
        tab_bar_edge = "top";
        allow_remote_control = "yes";
        #shell_integration = "enabled";
        #shell = "fish";
      };
      themeFile = "1984_orwellian";
    };

  };
}
