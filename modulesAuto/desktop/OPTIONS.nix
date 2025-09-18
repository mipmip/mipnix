{ lib, ... } : {

  options.nixos.desktop.enable = lib.mkEnableOption "enable desktop tools";
  options.nixos.virtualization.enable = lib.mkEnableOption "enable virtualization tools";
  options.nixos.bambulabs.enable = lib.mkEnableOption "enable bambulabs tools";
  options.nixos.desktopHyprland.enable = lib.mkEnableOption "enable hyprland tools";

}
