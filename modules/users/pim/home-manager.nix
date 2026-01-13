{ inputs, self, ... }:
{
  flake.homeConfigurations = {

    "pim@passieflora" = self.lib.makeHomeConf {
      hostname = "passieflora";
      desktop = true;
    };

    "pim@hurry" = self.lib.makeHomeConf {
      hostname = "hurry";
      system = "aarch64-linux";
    };

    "pim@harry" = self.lib.makeHomeConf {
      hostname = "harry";
      system = "aarch64-linux";
    };

    "pim@arcana-one" = self.lib.makeHomeConf {
      hostname = "arcana-one";
    };
  };

  flake.modules.homeManager.pim = {

    imports = with inputs.self.modules.homeManager; [
      pim-git
      pim-direnv
      pim-fzf
      pim-atuin
      pim-obs
      pim-shellstuff
      pim-alacritty
      pim-kitty
      pim-ghostty
      pim-firefox
      pim-librewolf
      pim-wrofi
      pim-awscli
      pim-aider
      pim-dirtygit
      pim-nix
      pim-npm
      pim-wtf
      pim-gimp
      pim-myhotkeys
      pim-thunderbird
      pim-fish
      pim-zsh
      pim-bmc
      pim-awscli-dir
      pim-smug-skull
      pim-freedesktop
      pim-pandoc
      pim-sc-im
      pim-vim
      pim-tmux
      pim-neovim
      pim-hyprland
      pim-fonts
#      pim-gnome-desktop-generic
#      pim-gnome-desktop-input-sources
#      pim-gnome-desktop-shortcuts
#      pim-gnome-extensions
    ];

    nixpkgs.config.allowUnfree = true;
  };

}

