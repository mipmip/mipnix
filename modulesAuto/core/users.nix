{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.ssh.startAgent = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.users.pim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.distrobox = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.annemarie = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

}

