{ config, lib, ... }:

let
  cfg = config.roles.desktop;
in

{
  imports = []
  ++
    map (n: "${../../_generic-for-contribution}/${n}") (lib.filter (n: lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) (builtins.attrNames (builtins.readDir ./../../_generic-for-contribution)))
   ++
    map (n: "${./fonts}/${n}") (lib.filter (n: (lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) || (builtins.readDir ./fonts).${n} == "directory") (builtins.attrNames (builtins.readDir ./fonts)))
  ++
    map (n: "${./gnome}/${n}") (lib.filter (n: (lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) || (builtins.readDir ./gnome).${n} == "directory") (builtins.attrNames (builtins.readDir ./gnome)))
  ++
    map (n: "${./programs}/${n}") (lib.filter (n: (lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) || (builtins.readDir ./programs).${n} == "directory") (builtins.attrNames (builtins.readDir ./programs)))
  ++
    map (n: "${./shared}/${n}") (lib.filter (n: (lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) || (builtins.readDir ./shared).${n} == "directory") (builtins.attrNames (builtins.readDir ./shared)))
  ++
    map (n: "${../../_roles}/${n}") (lib.filter (n: lib.hasSuffix ".nix" n && !(lib.hasSuffix ".moved" n)) (builtins.attrNames (builtins.readDir ./../../_roles)));

    #  options.roles.desktop = {
    #    enable = lib.mkEnableOption "Configure as desktop computer";
    #  };

  config = lib.mkIf cfg.enable {

    programs.tmux.shortcut = "a";

    desktopConf.freedesktop.enable = true;
    desktopConf.ghostty.enable = true;
    desktopConf.myhotkeys.enable = true;
    desktopConf.gimp.enable = true;
    desktopConf.smug.enable = true;
    desktopConf.alacritty.enable = true;
    desktopConf.kitty.enable = true;
    desktopConf.firefox.enable = true;
    desktopConf.librewolf.enable = true;
    desktopConf.obs.enable = true;

    zsh.enable = true;
    fish.enable = true;

    desktopConf.fonts.enable = true;
    desktopConf.gnome.enable = true;
  };
}
