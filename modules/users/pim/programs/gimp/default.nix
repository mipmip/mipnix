{
inputs,
...
}:
{
  flake.modules.homeManager.pim-gimp = {
    #GIMP SHORTCUTS
    home.file = {
      ".config/GIMP/2.10/menurc" = {
        source = ./menurc;
      };
    };
  };
}
