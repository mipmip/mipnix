{
inputs,
...
}:
{
  flake.modules.homeManager.pim-pandoc = {
    home.file = {
      ".pandoc" = {
        source = ./pandoc;
        recursive = true;
      };
    };
  };
}
