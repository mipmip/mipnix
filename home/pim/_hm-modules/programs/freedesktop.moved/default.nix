# LOOKING FOR ICONS?
# cd /run/current-system/sw/share/icons/hicolor/scalable/apps
{ config, lib, ... }:

let
  cfg = config.desktopConf.freedesktop;
in
  {

  options.desktopConf.freedesktop = {
    enable = lib.mkEnableOption "Enable freedesktop";
  };

  config = lib.mkIf cfg.enable {

    home.file = {
      ".local/share/icons" = {
        source = ./local-share-icons;
        recursive = true;
      };
    };

    home.file = {
      "./.Xmodmap" = {
        source = ./Xmodmap;
      };
    };
    home.file = {
      "./.Xresources" = {
        source = ./Xresources;
      };
    };

    xdg.desktopEntries = {

      st = {

        name           = "st";
        comment        = "st suckless terminal";
        genericName    = "st terminal";
        exec           = "st";
        categories     = [
          "TerminalEmulator"
        ];
        terminal       = false;
        startupNotify  = true;
        type           = "Application";
        icon           = "org.gnome.Console";
        settings       = {
          Keywords = "shell;prompt;command;commandline;cmd;";
          StartupWMClass = "xterm-256color";
        };
      };

      gvim = {
        name           = "gvim";
        comment        = "Edit text files";
        genericName    = "Text editor";
        exec           = "gvim --remote-tab-silent %F";
        categories     = [
          "Utility"
          "TextEditor"
        ];
        terminal       = false;
        startupNotify  = true;
        type           = "Application";
        icon           = "gvim";
        settings       = {
          Keywords = "Text;editor;";
        };
      };

      firefox-extra = {
        name           = "Firefox Extra";
        comment        = "Extra Firefox with other icon";
        genericName    = "Extra Web Browser";
        exec           = "firefox";
        categories     = [ "Network" ];
        terminal       = false;
        startupNotify  = true;
        type           = "Application";
        icon           = "ffextra";
        settings       = {
          Keywords = "browser;";
          StartupWMClass = "ffextra";
        };
      };

      quiqr-desktop = {

        name           = "Quiqr Desktop";
        comment        = "Quiqr Desktop";
        genericName    = "quiqr desktop";
        exec           = "st";
        categories     = [ "TerminalEmulator" ];
        terminal       = false;
        startupNotify  = true;
        type           = "Application";
        icon           = "org.quiqr.quiqr-desktop";
        settings       = {
          Keywords = "shell;prompt;command;commandline;cmd;";
          StartupWMClass = "quiqr";
        };
      };
    };
  };
}
