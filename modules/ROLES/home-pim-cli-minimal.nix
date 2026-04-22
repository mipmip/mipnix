{
inputs,
...
}:
{
  flake.modules.homeManager.role-pim-cli-minimal = {

    imports = with inputs.self.modules.homeManager; [
      mip-theme
      pim-git
      pim-fish
      pim-fzf

      pim-tmux
      pim-shellstuff-cli

      pim-shared-shell-aliases
    ];

    programs.vim = {
      enable = true;
    };

  };
}

