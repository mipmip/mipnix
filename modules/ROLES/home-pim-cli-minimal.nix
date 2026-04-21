{
inputs,
...
}:
{
  flake.modules.homeManager.role-pim-cli-minimal = {

    imports = with inputs.self.modules.homeManager; [
      pim-homeWith-options
      mip-theme
      pim-git
      pim-shellstuff
      pim-fish
      pim-fzf
      pim-tmux
      pim-shared-shell-aliases
    ];

    programs.vim = {
      enable = true;
    };

  };
}

