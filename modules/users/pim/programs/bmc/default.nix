{
inputs,
...
}:
{
  flake.modules.homeManager.pim-bmc = {
    home.file = {
      ".config/bmc" = {
        source = ./bmc;
        recursive = true;
      };
    };
  };
}
