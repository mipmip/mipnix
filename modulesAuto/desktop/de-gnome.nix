{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {

    services.gnome.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      #wlr.enable = true;
      extraPortals = [
        #pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };


    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs; [
        cheese # webcam tool
        gnome-music
        #gedit # text editor
        epiphany # web browser
        geary # email reader
        #gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        #gnome-contacts
        gnome-initial-setup
      ]);

    environment.systemPackages = with pkgs; [

      #NIX/GNOME/HOMEMANAGER
      dconf2nix

      # NEMO-DESKTOP
      nemo

      # GrandPerspective
      baobab

      # SCREENCAST
      #peek
      #kooha

      # MAIL
      # evolution

      # UTILS
      gnome-tweaks
      gpaste
      #gnome-secrets

      # IMAGE
      #gnome.gnome-screenshot
      #mipmip_pkg.gnome-screenshot
      #gthumb

      #DEV
      glib.dev
      #glade
      #cambalache
      #gnome-builder

      #RSS
      #newsflash
    ];


    programs = {
      gpaste.enable = true;
    };
  };
}

