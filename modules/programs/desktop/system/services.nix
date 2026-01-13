{ inputs, ... } : {
  flake.modules.nixos.desktop-system-services = { config, pkgs, ... }: {
    #services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;

    # IF TRUE WAYLAND WILL BE USED
    services.displayManager.gdm.enable = true;
    services.displayManager.defaultSession = "hyprland";

    services.flatpak.enable = true;

    # Configure keymap in X11
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.options = "caps:none,terminate:ctrl_alt_bks";
  };
}
