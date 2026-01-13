{
inputs,
...
}:
{
  flake.modules.homeManager.pim-obs = { config, lib, ... }: {
    options.desktopConf.obs = {
      enable = lib.mkEnableOption "configure obs";
    };

    config = lib.mkIf config.desktopConf.obs.enable {
    };
  };
}
