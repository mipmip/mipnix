{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.gnome;
in

{


  config = lib.mkIf cfg.enable {

    dconf.settings = {

      "org/gnome/desktop/wm/keybindings" = {
        close                        = [ "<Super>q" ];
        cycle-windows-backward       = [ "<Shift><Super>Escape" ];
        maximize                     = [ "<Super>Up" ];
        toggle-maximized             = [ "<Super>t" ];
        minimize                     = [ "<Alt>F4" ];
        move-to-workspace-1          = [];
        move-to-workspace-2          = [];
        move-to-workspace-3          = [];
        move-to-workspace-4          = [];
        show-desktop                 = [ "F12" ];
        switch-input-source          = [];
        switch-input-source-backward = [];
        switch-to-workspace-1        = [];
        switch-to-workspace-2        = [];
        switch-to-workspace-3        = [];
        switch-to-workspace-4        = [];
        switch-to-workspace-last     = [];
        toggle-fullscreen            = [ "<Super>f" ];
        cycle-windows                = [ "<Super>Escape" ];
      };

      "org/gnome/shell/keybindings" = {
        toggle-quick-settings        = [ "<Shift><Control>s" ];
      };

      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ "<Primary><Shift>Left" ];
        toggle-tiled-right = [ "<Primary><Shift>Right" ];
      };

      # FIX OVERLAP WITH SUPER ESCAPE CYCLE WINDOWS
      "org/gnome/mutter/wayland/keybindings" = {
        restore-shortcuts=[""];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
        ];
        screensaver = [];
        search = [ "<Super>/" ];
      };


    };
  };
}
