{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.gnome;

  gnomeExtensionsWithOutConf = [
    pkgs.gnomeExtensions.emoji-copy
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.wayland-or-x11
    pkgs.gnomeExtensions.dash-to-dock
  ];

  gnomeExtensions = map (ext: { extpkg = ext; } ) gnomeExtensionsWithOutConf ++ [
  ];

  dconfEnabledExtensions = {

    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "writer.desktop"
        "org.gnome.Geary.desktop"
        "rustdesk.desktop"
        "signal-desktop.desktop"
      ];
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
      toggle-application-view = [ "" ];
      toggle-overview = [ "" ];
    };


    "org/gnome/shell" = {
      enabled-extensions = map (ext: ext.extpkg.extensionUuid) gnomeExtensions ++ [
        "GPaste@gnome-shell-extensions.gnome.org"
      ];
    };
  };

  dconfExtConfs = builtins.listToAttrs (builtins.catAttrs "dconf" gnomeExtensions);
  recursiveMerge = import ./recursive-merge.nix {lib = lib;};
in
{

  config = lib.mkIf cfg.enable {
    home.packages = map (ext: ext.extpkg) gnomeExtensions;
    dconf.settings = recursiveMerge [dconfEnabledExtensions dconfExtConfs];
  };
}
