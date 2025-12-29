{ config, lib, pkgs, unstable, ... }:

{
  config = lib.mkIf config.nixos.ai.enable {
    environment.systemPackages = with pkgs; [
      #unstable.aider-chat-full
      unstable.aider-chat-with-bedrock

      unstable.aichat

      unstable.plandex
      unstable.plandex-server

      mods
    ];
  };
}
