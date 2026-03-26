{
inputs,
...
}:
{
  flake.modules.homeManager.pim-fzf = {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
