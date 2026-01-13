{
inputs,
...
}:
{
  flake.modules.homeManager.pim-gimp = { config, lib, ... }: {
    options.desktopConf.gimp = {
      enable = lib.mkEnableOption "Configure gimp";
    };

    config = lib.mkIf config.desktopConf.gimp.enable {
      #GIMP SHORTCUTS
      home.file = {
        ".config/GIMP/2.10/menurc" = {
          source = ./menurc;
        };
      };
    };
  };
}
