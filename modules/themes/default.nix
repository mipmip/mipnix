{
  ...
}:
let
  colors = import ../../lib/colors.nix;
in
{
  flake.modules.homeManager.mip-theme = { lib, ... }: {
    options.mip.theme.colors = {
      bg = {
        active = lib.mkOption {
          type = lib.types.str;
          default = colors.bg.active;
          description = "Background color for active windows/panes";
        };
        inactive = lib.mkOption {
          type = lib.types.str;
          default = colors.bg.inactive;
          description = "Background color for inactive windows/panes";
        };
      };
    };
  };
}
