{ inputs, ... } : {
  flake.modules.nixos.desktop-de-elementary = { config, pkgs, ... }: {

    #services.desktopManager.pantheon.enable = true;
    services.pantheon.apps.enable = true;
  };
}
