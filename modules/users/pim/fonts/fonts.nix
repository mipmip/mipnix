{
inputs,
...
}:
{
  flake.modules.homeManager.pim-fonts = { config, lib, pkgs, ... }: {

    options.desktopConf.fonts = {
      enable = lib.mkEnableOption "Enable freedesktop";
    };

    config = lib.mkIf config.desktopConf.fonts.enable {

      fonts.fontconfig.enable = true;
      #    home.packages = [
      #      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      #    ];

    };
  };
}
