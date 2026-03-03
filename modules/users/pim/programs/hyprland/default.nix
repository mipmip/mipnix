{
inputs,
...
}:
{
  flake.modules.homeManager.pim-hyprland = { pkgs, system, ... }: {
    home.file = {
      ".config/hypr" = {
        source = ./hypr;
        recursive = true;
      };
      ".config/hypr/scripts" = {
        source = ./scripts;
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

    imports = [
      #inputs.elephant.homeManagerModules.default
      inputs.walker.homeManagerModules.default
    ];

    programs.elephant = {
      enable = true;
      debug = false;

      # Select specific providers
      providers = [
        #"files"
        "desktopapplications"
        "calc"
        "runner"
        "clipboard"
        "symbols"
        "websearch"
        "menus"
        "providerlist"
      ];

      # Custom elephant configuration
      settings = {
        providers = {
          files = {
            min_score = 50;
            icon = "folder";
          };
          desktopapplications = {
            launch_prefix = "uwsm app --";
            min_score = 60;
          };
          calc = {
            icon = "accessories-calculator";
          };
        };
      };
    };


    programs.walker = {
      enable = true;
      runAsService = true;
    };

    home.packages = [ inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default ];

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

  };
}
