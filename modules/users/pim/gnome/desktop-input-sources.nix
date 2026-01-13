{
inputs,
...
}:
{
  flake.modules.homeManager.pim-gnome-desktop-input-sources = { config, lib, ... }:
  let
    mkTuple = lib.hm.gvariant.mkTuple;

     xkb-options = lib.lists.optional config.desktopConf.gnome.swapAltWin "altwin:swap_alt_win" ++ [
          "grp:alt_shift_toggle"
          "lv3:ralt_switch"
          "compose:ralt"
          "caps:none"
        ];
  in
  {

    options.desktopConf.gnome = {
      swapAltWin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to swap Alt and Win keys";
      };
    };

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
        per-window = false;
        sources = [ (mkTuple [ "xkb" "us" ]) ];
        xkb-options = xkb-options;
      };
    };
  };
}
