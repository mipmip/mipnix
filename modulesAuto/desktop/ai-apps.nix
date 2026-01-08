{
  config,
  lib,
  pkgs,
  ...
}:
{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.cherry-studio
      pkgs.unstable.jan
      pkgs.unstable.newelle
      pkgs.unstable.sillytavern
      pkgs.unstable.chatbox

    ];
  };
}
