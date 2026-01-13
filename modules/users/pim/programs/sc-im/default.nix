{
inputs,
...
}:
{
  flake.modules.homeManager.pim-sc-im = {
    home.file = {
      ".config/sc-im" = {
        source = ./sc-im;
        recursive = true;
      };
    };
  };
}
