{ config, lib, pkgs, unstable,  ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [

      # PDF
      zathura
      pdftk
      pdfarranger
      ghostscript
      #paperwork # could replace papermerge

      gimp
      unstable.gimp3-with-plugins
      unstable.inkscape-with-extensions
      #krita

      #nixpkgs-inkscape13.inkscape
      feh
      #swappy

      #emulsion-palette

      blender

      libreoffice


    ];

  };
}

