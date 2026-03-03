{ inputs, ... } : {
  flake.modules.nixos.desktop-de-kde = { config, pkgs, ... }: {
    services.desktopManager.plasma6.enable = true;
  };
}

