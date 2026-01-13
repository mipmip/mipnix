{
inputs,
...
}:
{
  flake.modules.homeManager.pim-alacritty = { config, lib, ... }: {
    options.desktopConf.alacritty = {
      enable = lib.mkEnableOption "Enable alacritty";
    };

    config = lib.mkIf config.desktopConf.alacritty.enable {
      programs.alacritty = {
        enable = true;

        settings = {
          window.padding = {
            x = 10;
            y = 10;
          };
          font.normal = {
            family = "DejaVu Sans Mono";
            style = "Regular";
          };
        };
      };
    };
  };
}
