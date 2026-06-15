{ inputs, ... } : {
  flake.modules.nixos.desktop-de-hyprland = { config, pkgs, ... }: {

    programs = {
      dconf.enable = true;
      xwayland.enable = true;

      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        #plugins = [
        #  inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        #];

      };
    };

    security.polkit.enable = true;

    # SVG support in GTK apps. This Hyprland session is launched by GDM and does
    # NOT run a full GNOME/KDE session, so nothing sets GDK_PIXBUF_MODULE_FILE
    # session-wide. Without it, GdkPixbuf falls back to the default loaders
    # cache, which lacks the SVG loader (librsvg is a separate package), so SVGs
    # fail to render everywhere. This module builds a combined loaders.cache and
    # sets GDK_PIXBUF_MODULE_FILE via environment.sessionVariables (/etc/set-
    # environment), which the GDM session — and thus every GTK app launched from
    # Hyprland — inherits.
    services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

    #services.displayManager.sessionPackages = [ pkgs.upstream-hyprland.hyprland ];

    #    xdg.portal = {
    #      enable = true;
    #      wlr.enable = true;
    #      extraPortals = [
    #        pkgs.xdg-desktop-portal-hyprland
    #      ];
    #    };
    #
    #    services.input-remapper = {
    #      enable = true;
    #    };

    # Hint Electon apps to use wayland
    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    environment.systemPackages = with pkgs; [

      pamixer

      #hyprland
      hyprlock
      hyprshot
      hyprnome
      hyprcursor
      hyprmon
      hyprviz
      rose-pine-hyprcursor

      nwg-displays
      swaynotificationcenter
      wpaperd

      libinput
      wl-clipboard

      # Required by the workspace-monitor-rehome script (reads Hyprland socket2).
      socat

      #ashell  # replaced by mipbar

      swayidle

      cliphist

      wofi
      awww

      #xdg-desktop-portal-gtk
      #xdg-desktop-portal-hyprland
      #xwayland
      #hyprshell
    ];

  };
}
