{
inputs,
...
}:
{
  flake.modules.homeManager.pim-myhotkeys = {
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
}
