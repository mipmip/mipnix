{ config, pkgs,unstable, ... }:

{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    defaultEditor = true;
  };

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };

  home.file = {
    ".config/mcphub" = {
      source = ./mcphub;
      recursive = true;
    };
  };


  programs.hm-ricing-mode.apps.mcphub = {
    dest_dir = ".config/mcphub";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/neovim/mcphub";
    type = "symlink";
  };

  programs.hm-ricing-mode.apps.neovim = {
    dest_dir = ".config/nvim";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/neovim/nvim";
    type = "symlink";
  };

  home.packages = [
    #    pkgs.lua51Packages.lua
    #    pkgs.luajitPackages.magick
    #    pkgs.lua51Packages.luarocks
    pkgs.gnumake
    pkgs.gcc
    pkgs.pkg-config
    pkgs.smug
    pkgs.awscli2
    pkgs.typescript-language-server

    pkgs.nil
    pkgs.terraform-ls
    pkgs.silver-searcher
    pkgs.fzf
    pkgs.ripgrep
  ];
}

