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
