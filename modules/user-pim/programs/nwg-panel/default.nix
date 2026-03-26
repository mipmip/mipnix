{
inputs,
...
}:
{
  flake.modules.homeManager.pim-nwg-panel = { config, pkgs, ... }: {

    # Deploy nwg-panel configuration files
    home.file = {
      ".config/nwg-panel/config" = {
        source = ./config;
      };
      ".config/nwg-panel/style.css" = {
        source = ./style.css;
      };
    };

    # Enable ricing mode for nwg-panel
    programs.hm-ricing-mode.apps.nwg-panel = {
      dest_dir = ".config/nwg-panel";
      source_dir = "$HOME/nixos/modules/users/pim/programs/nwg-panel";
      type = "symlink";
    };
  };
}
