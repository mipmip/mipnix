{ inputs, ... } : {
  flake.modules.nixos.desktop-system-services = { config, pkgs, ... }: {
    services.desktopManager.gnome.enable = true;

    # IF TRUE WAYLAND WILL BE USED
    services.displayManager.gdm.enable = true;
    services.displayManager.defaultSession = "hyprland";

    services.flatpak.enable = true;

    # Use the reference dbus-daemon instead of dbus-broker (the NixOS 26.05
    # default). With dbus-broker, xdg-desktop-portal's caller-verification step
    # for ScreenCast fails — the portal opens /proc/<caller-pid>/root to detect
    # the app (flatpak-info), and gets:
    #   AccessDenied: Portal operation not allowed: Unable to open /proc/<pid>/root
    # so Slack (and other Electron apps) can't screen-share. This is a known
    # dbus-broker + xdg-desktop-portal interaction; the reference dbus-daemon
    # ("dbus") passes caller credentials in the way the portal expects. See the
    # electron-wayland-screenshare change.
    services.dbus.implementation = "dbus";

    # Configure keymap in X11
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.options = "caps:none,terminate:ctrl_alt_bks";
  };
}
