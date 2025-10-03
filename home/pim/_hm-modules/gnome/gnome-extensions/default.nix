{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.desktopConf.gnome;

  mipmip_pkg = import (./pkgs){inherit pkgs;};

  gnomeExtensionsWithOutConf = [
    #mipmip_pkg.gnomeExtensions.custom-menu-panel
    pkgs.gnomeExtensions.emoji-copy
    pkgs.gnomeExtensions.caffeine
    #pkgs.gnomeExtensions.espresso
    pkgs.gnomeExtensions.show-favorite-apps
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.spotify-tray
    pkgs.gnomeExtensions.wayland-or-x11
    pkgs.gnomeExtensions.clipboard-indicator
    #pkgs.gnomeExtensions.tailscale-status
  ];

  gnomeExtensions = map (ext: { extpkg = ext; } ) gnomeExtensionsWithOutConf ++ [

    (import ./shell-ext-color-picker.nix { pkgs = pkgs; })
    (import ./shell-ext-focus-changer.nix { pkgs = pkgs; })
    (import ./shell-ext-dash-to-panel.nix { pkgs = pkgs; })
    (import ./shell-ext-useless-gaps.nix { unstable = unstable; })
    (import ./shell-ext-highlight-focus.nix { inherit unstable; })
    #    (import ./shell-ext-search-light.nix { lib = lib; mipmip_pkg = mipmip_pkg; inherit unstable; })

  ];

  dconfEnabledExtensions = {

    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "firefox.desktop"
        "com.mitchellh.ghostty.desktop"
        "org.gnome.Nautilus.desktop"
        "org.inkscape.Inkscape.desktop"
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
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
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
