{
  config,
  pkgs,
  unstable,
  ...
}:

{
  home.file = {
    ".config/hypr" = {
      source = ./hypr;
      recursive = true;
    };
  };

  programs.hm-ricing-mode.apps.hypr = {
    dest_dir = ".config/hypr";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/hyprland/hypr";
    type = "symlink";
  };

  home.file = {
    ".config/ashell" = {
      source = ./ashell;
      recursive = true;
    };
  };

  home.file = {
    ".config/walker" = {
      source = ./walker;
      recursive = true;
    };
  };

  home.file = {
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };
  };

  programs.hm-ricing-mode.apps.waybar = {
    dest_dir = ".config/waybar";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/hyprland/waybar";
    type = "symlink";
  };

}
