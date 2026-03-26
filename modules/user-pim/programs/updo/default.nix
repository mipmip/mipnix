{
inputs,
...
}:
{
  flake.modules.homeManager.pim-monitoring = {
        home.file = {
          ".config/updo" = {
            source = ./updo;
            recursive = true;
          };
        };
  };
}

