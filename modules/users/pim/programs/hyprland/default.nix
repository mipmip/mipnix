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



    programs.walker = {
      enable = true;
      runAsService = true;
      elephant = {
        providers = [
          "calc"
          "clipboard"
          "desktopapplications"
          # "files" # files provider starts very slowly
          "menus"
          "providerlist"
          "runner"
          "symbols"
          "todo"
          "unicode"
          "websearch"
        ];
      };
    };

    home.packages = [ inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    #    programs.walker = {
    #      enable = true;
    #      runAsService = true; # Note: this option isn't supported in the NixOS module only in the home-manager module
    #
    #    };

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
