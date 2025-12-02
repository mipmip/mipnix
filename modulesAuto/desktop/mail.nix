{ config, unstable, pkgs, ... }:{
    environment.systemPackages = with pkgs; [
      unstable.fastmail-desktop
    ];
}
