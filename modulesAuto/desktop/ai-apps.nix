{ config, lib, pkgs, unstable, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      unstable.cherry-studio
      unstable.jan
      unstable.newelle
      unstable.sillytavern
      unstable.chatbox

    ];
  };
}

