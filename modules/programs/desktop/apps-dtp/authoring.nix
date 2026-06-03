{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-dtp = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      gimp
      gimp3-with-plugins
      inkscape-with-extensions
      #krita

      #nixpkgs-inkscape13.inkscape
      feh
      #swappy

      emulsion-palette

      blender

      libreoffice


    ];

  };
}
