{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.firefox
      librewolf
    ];

  };
}
