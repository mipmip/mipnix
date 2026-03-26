{
...
}:
{
  flake.modules.homeManager.pim-with-desktop = { lib, config, ... }: {
    homeWith.desktop.enable = true;
      programs.tmux.shortcut = "a";
    #desktopConf.fonts.enable = true;
    #  desktopConf.gnome.enable = true;
    };
}

