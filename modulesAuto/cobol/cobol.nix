{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.nixos.full.enable {
    environment.systemPackages = with pkgs; [
      jdk17
    ];
  };
}
