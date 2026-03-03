{ inputs, ... } : {

  flake.modules.nixos.desktop-apps-dtp = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      # Viewers
      zathura
      sioyek # keyboard driven pdf viewer

      zotero # document organizer

      # Tools
      pdftk
      pdfarranger
      ghostscript

      #paperwork # could replace papermerge




    ];

  };
}

