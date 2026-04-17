{
inputs,
...
}:
{
  flake.modules.homeManager.pim-direnv = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
