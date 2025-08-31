{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.jdk17
  ];
}
