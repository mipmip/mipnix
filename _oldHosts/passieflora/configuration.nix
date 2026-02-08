{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./sleep.nix
      ./apps.nix
    ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  i18n.defaultLocale = "nl_NL.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh.enable = true;

  services.cron.enable = true;

  services.journald.extraConfig = "SystemMaxUse=100M";

  users.defaultUserShell = pkgs.zsh;

  environment.shells = with pkgs; [ zsh ];

  users.users.pim = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  users.users.annemarie = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
  };

  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "passieflora"; # Define your hostname.

  time.timeZone = "Europe/Amsterdam";

  #services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true;

  programs.zsh.enable = true;
  programs = {
    gpaste.enable = true;
    zsh.ohMyZsh.enable = true;
  };

  nixos-boot = {
    enable  = true;
    theme = "grannyos";

    bgColor.red   = 0; # 0 - 255
    bgColor.green = 212; # 0 - 255
    bgColor.blue  = 255; # 0 - 255

    # If you want to make sure the theme is seen when your computer starts too fast
    # duration = 3; # in seconds
  };

  services.tailscale.enable = true;

  system.stateVersion = "24.11";

}
