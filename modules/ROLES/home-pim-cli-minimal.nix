{
inputs,
...
}:
{
  flake.modules.homeManager.role-pim-cli-minimal = {

    imports = with inputs.self.modules.homeManager; [
      pim-git
      pim-shellstuff
      pim-fish
      pim-fzf
      pim-tmux
    ];

  };
}

