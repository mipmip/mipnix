{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [

      # PDF
      zathura
      pdftk
      pdfarranger
      ghostscript
      #paperwork # could replace papermerge

      gimp
      pkgs.unstable.gimp3-with-plugins
      pkgs.unstable.inkscape-with-extensions
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

