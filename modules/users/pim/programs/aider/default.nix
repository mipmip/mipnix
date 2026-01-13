{
inputs,
...
}:
{
  flake.modules.homeManager.pim-aider = {
    home.file = {
      "./.aider.conf.yml" = {
        source = ./.aider.conf.yml;
      };
    };
  };
}
