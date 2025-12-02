{ config,lib, unstable, pkgs, ... }:{
  config = lib.mkIf config.nixos.full.enable {
    environment.systemPackages = with pkgs; [
      unstable.fastmail-desktop
    ];
  };
}
