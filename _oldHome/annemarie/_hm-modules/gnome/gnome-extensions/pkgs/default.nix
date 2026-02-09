{ pkgs }:
#{ pkgs }:

let
  callPackage = pkgs.newScope self;
  self = {

    gnomeExtensions.gs-git                = pkgs.callPackage ./gnome-shell-extensions/gs-git                { };
    gnomeExtensions.vitals                = pkgs.callPackage ./gnome-shell-extensions/vitals                { };
    gnomeExtensions.custom-menu-panel     = pkgs.callPackage ./gnome-shell-extensions/custom-menu-panel     { };
    gnomeExtensions.github-notifications  = pkgs.callPackage ./gnome-shell-extensions/github-notifications  { };
    gnomeExtensions.highlight-focus       = pkgs.callPackage ./gnome-shell-extensions/highlight-focus       { };
    gnomeExtensions.search-light          = pkgs.callPackage ./gnome-shell-extensions/search-light          { };
  };
in self
