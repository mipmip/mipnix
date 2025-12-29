{ config, lib, pkgs, unstable, ... }:

{
  config = lib.mkIf config.nixos.litellm.enable {
    environment.systemPackages = with pkgs; [
    ];

    services.litellm = {
      enable = true;
    };
  };
}

