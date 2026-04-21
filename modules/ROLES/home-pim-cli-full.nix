{
inputs,
...
}:
{
  flake.modules.homeManager.role-pim-cli-full = { lib, config, ... }: {

    programs.hm-ricing-mode.enable = true;
    nixpkgs.config.allowUnfree = true;
    homeWith.secondbrain.enable = true;

    home.file = {
      "${config.home.homeDirectory}/.i-am-second-brain" = {
        text = '''';
      };

    };

    imports = with inputs.self.modules.homeManager; [
      pim-direnv
      pim-atuin
      pim-yazi
      pim-awscli
      pim-nix
      pim-npm
      pim-wtf
      pim-zsh
      pim-bmc
      pim-awscli-dir
      pim-smug-skull
      pim-pandoc
      pim-sc-im
      pim-vim
      pim-neovim
      vibecoding-opencode
      vibecoding-claude-code-config
    ];

  };
}


