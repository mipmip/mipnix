{ inputs, ... } : {
  flake.modules.nixos.desktop-de-hyprland = { config, pkgs, ... }: {

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

    services.input-remapper = {
      enable = true;
    };

    # Hint Electon apps to use wayland
    environment.sessionVariables = {

      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      #NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      #waybar
      pkgs.unstable.noctalia-shell
      pamixer

      rofi
      hyprland
      hyprlock
      hyprshot
      hyprnome
      nwg-displays
      libinput
      swaynotificationcenter

      wpaperd
      wl-clipboard

      hyprcursor
      rose-pine-hyprcursor

      ashell
      #walker

      swayidle

      cliphist
      wl-clipboard

      wofi
      swww # for wallpapers
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      #xwayland
      pkgs.unstable.hyprshell
      hyprmon
      hyprviz
    ];

  };
}
