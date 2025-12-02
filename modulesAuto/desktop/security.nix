{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      bitwarden-desktop
      lynis
    ];
  };
}


