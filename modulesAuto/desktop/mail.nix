{ config,lib, pkgs, ... }:{
  config = lib.mkIf config.nixos.full.enable {
    environment.systemPackages = with pkgs; [
      #pkgs.unstable.fastmail-desktop
    ];
  };
}
