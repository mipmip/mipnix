{ inputs, ... } : {
  flake.modules.nixos.desktop-de-hyprland = { config, pkgs, ... }: {

    programs = {
      dconf.enable = true;
      xwayland.enable = true;
    };

    security.polkit.enable = true;

    services.displayManager.sessionPackages = [ pkgs.unstable-hyprland.hyprland ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.unstable-hyprland.xdg-desktop-portal-hyprland
      ];
    };

    services.input-remapper = {
      enable = true;
    };

    # Hint Electon apps to use wayland
    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    environment.systemPackages = with pkgs.unstable-hyprland; [

      pamixer

      #rofi
      hyprland
      hyprlock
      hyprshot
      hyprnome
      nwg-displays
      #nwg-panel
      libinput
      swaynotificationcenter

      wpaperd
      wl-clipboard

      hyprcursor
      rose-pine-hyprcursor

      waybar
      ashell
      # ashell removed from autostart - replaced by waybar
      #walker

      swayidle

      cliphist
      wl-clipboard

      wofi
      swww # for wallpapers
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      #xwayland
      hyprshell
      hyprmon
      hyprviz
    ];

  };
}
