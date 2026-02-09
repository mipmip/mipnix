{ config, lib, ... }:

let
  cfg = config.desktopConf.gnome;
in

{
  options.desktopConf.gnome = {
    enable = lib.mkEnableOption "Configure gnome";
  };

  config = lib.mkIf cfg.enable {

    dconf.settings = {

      "org/gnome/GPaste" = {
        history-name = "history";
        show-history = "<Ctrl>space";
        images-support = true;
        primary-to-history = true;
        synchronize-clipboards = true;
        track-changes = true;
        track-extension-state = true;
        trim-items = true;
      };

      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
      };

      "org/gnome/desktop/interface" = {
        clock-format = "24h";
        clock-show-weekday = false;
        cursor-theme = "Adwaita";
        enable-animations = true;
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "none";
        font-name = "Liberation Sans 10";
        gtk-enable-primary-paste = false;
        gtk-im-module = "gtk-im-context-simple";
        gtk-theme = "Adwaita";
        icon-theme = "Adwaita";
        text-scaling-factor = 1.0;
        toolbar-style = "text";
      };


      "org/gnome/desktop/wm/preferences" = {
        action-double-click-titlebar = "minimize";
        auto-raise                   = true;
        button-layout                = "close:appmenu";
        focus-mode                   = "click";
        num-workspaces               = 1;
        resize-with-right-button     = false;
        theme                        = "Default";
        #workspace-names              = [ "1" "2" "3" "4" ];
      };

      "org/gnome/settings-daemon/plugins/xsettings" = {
        overrides = "{'Gtk/EnablePrimaryPaste': <0>, 'Gtk/DecorationLayout': <'close,minimize,maximize:menu'>, 'Gtk/ShellShowsAppMenu': <0>, 'Gtk/DialogsUseHeader': <0>}";
      };

      #      "org/gnome/mutter" = {
      #        center-new-windows = true;
      #        dynamic-workspaces = false;
      #        overlay-key = "Super_R";
      #        workspaces-only-on-primary = true;
      #        experimental-features = ["scale-monitor-framebuffer"];
      #      };
    };
  };
}
