{
  config,
  lib,
  pkgs,
  ...
}:
{

  config = lib.mkIf config.nixos.desktopHyprland.enable {

    programs = {
      dconf.enable = true;
      xwayland.enable = true;
    };

    security.polkit.enable = true;

    services.displayManager.sessionPackages = [ pkgs.hyprland ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        #pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Hint Electon apps to use wayland
    #  environment.sessionVariables = {
    #    NIXOS_OZONE_WL = "1";
    #  };

    environment.systemPackages = with pkgs; [
      waybar
      pamixer

      rofi
      hyprland
      hyprlock
      hyprshot
      hyprnome
      nwg-displays
      libinput

      wpaperd

      hyprcursor
      rose-pine-hyprcursor

      ashell
      walker

      swayidle

      cliphist
      wl-clipboard

      wofi
      swww # for wallpapers
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xwayland
      hyprshell
      hyprmon
      hyprviz
    ];

  };
}
