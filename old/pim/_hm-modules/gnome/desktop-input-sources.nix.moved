{ config, lib, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
  cfg = config.desktopConf;
in

{
  options.desktopConf.gnome = {
    swapAltWin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to swap Alt and Win keys";
    };
  };

  config = lib.mkIf cfg.gnome.enable (
    let

       xkb-options = lib.lists.optional config.desktopConf.gnome.swapAltWin "altwin:swap_alt_win" ++ [
            "grp:alt_shift_toggle"
            "lv3:ralt_switch"
            "compose:ralt"
            "caps:none"
          ];
    in
    {
      dconf.settings = {
        "org/gnome/desktop/input-sources" = {
          mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
          per-window = false;
          sources = [ (mkTuple [ "xkb" "us" ]) ];
          xkb-options = xkb-options;
        };
      };
    }
  );
}
