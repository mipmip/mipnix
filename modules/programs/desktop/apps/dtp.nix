{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-dtp = { config, pkgs, ... }: {
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
