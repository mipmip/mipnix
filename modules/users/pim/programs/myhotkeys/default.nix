{
inputs,
...
}:
{
  flake.modules.homeManager.pim-myhotkeys = { config, lib, ... }: {
    options.desktopConf.myhotkeys = {
      enable = lib.mkEnableOption "Enable freedesktop";
    };

    config = lib.mkIf config.desktopConf.myhotkeys.enable {
      home.file = {
        "./.config/myhotkeys/keys.json" = {
          source = ./myhotkeys.json;
        };
      };

      #  programs.myhotkeys."Gnome Extra".cyclewindow.key = "<ALT>grave";
      #  programs.myhotkeys."Gnome Extra".cyclewindow.description = "Cycle windows within same Application";
      #  programs.myhotkeys.enable = true;
      #  programs.myhotkeys.hotkey_groups = [
      #    {
      #      name = "Gnome Extra";
      #      shortcuts = [
      #        {
      #          key = "<ALT>grave";
      #          description = "Cycle windows within same Application";
      #        }
      #      ];
      #    }
      #
      #  ];

    };
  };
}
