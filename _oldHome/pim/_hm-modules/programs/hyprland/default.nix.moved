{
  inputs,
  system,
  ...
}:

{
  home.file = {
    ".config/hypr" = {
      source = ./hypr;
      recursive = true;
    };
  };

  programs.hm-ricing-mode.apps.hypr = {
    dest_dir = ".config/hypr";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/hyprland/hypr";
    type = "symlink";
  };

  home.file = {
    ".config/ashell" = {
      source = ./ashell;
      recursive = true;
    };
  };

  #todo use stdenv.hostPlatform.system
  home.packages = [ inputs.walker.packages.${system}.default ];
  programs.walker = {
    enable = true;
    runAsService = true; # Note: this option isn't supported in the NixOS module only in the home-manager module

    # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
    #    config = {
    #      theme = "your theme name";
    #      placeholders."default" = {
    #        input = "Search";
    #        list = "Example";
    #      };
    #      providers.prefixes = [
    #        {
    #          provider = "websearch";
    #          prefix = "+";
    #        }
    #        {
    #          provider = "providerlist";
    #          prefix = "_";
    #        }
    #      ];
    #      keybinds.quick_activate = [
    #        "F1"
    #        "F2"
    #        "F3"
    #      ];
    #    };
    #
    #    # Set `programs.walker.config.theme="your theme name"` to choose the default theme
    #    themes = {
    #      "your theme name" = {
    #        # Check out the default css theme as an example https://github.com/abenz1267/walker/blob/master/resources/themes/default/style.css
    #        style = " /* css */ ";
    #
    #        # Check out the default layouts for examples https://github.com/abenz1267/walker/tree/master/resources/themes/default
    #        layouts = {
    #          "layout" = " <!-- xml --> ";
    #          "item_calc" = " <!-- xml --> ";
    #          # other provider layouts
    #        };
    #      };
    #      "other theme name" = {
    #        # ...
    #      };
    #      # more themes
    #    };
  };

  #  home.file = {
  #    ".config/walker" = {
  #      source = ./walker;
  #      recursive = true;
  #      force = true;
  #    };
  #  };

  home.file = {
    ".config/wpaperd" = {
      source = ./wpaperd;
      recursive = true;
    };
  };

  home.file = {
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };
  };

  programs.hm-ricing-mode.apps.waybar = {
    dest_dir = ".config/waybar";
    source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/hyprland/waybar";
    type = "symlink";
  };

}
