{ config, inputs, system, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    #./nextcloud.nix
    ./seafile.nix
    #./matrix.nix
    ./nebula.nix
    #    ./cloudflared.nix
    #../../modules/base-core.nix
    #../../modules/base-hardware.nix
    #    ../../modules/nix-common.nix
    ../../modules/network-nfs-piet.nix
    #../../modules/nix-home-manager-global.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    firewall.enable = false;
    hostName = "harry";
  };

  environment.systemPackages = with pkgs; [
    home-manager
    nfs-utils
    vim
    tmux
    git
    htop
    libraspberrypi
    #    cloudflared
    raspberrypi-eeprom
  ];

  services.openssh.enable = true;
  #services.tailscale.enable = true;


  users = {
    mutableUsers = true;
    users.pim = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";


  nix = {
    package = pkgs.nixVersions.stable;
    settings.trusted-substituters = [
      "http://attic.np-tools.technative.cloud:8080/jeroen"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
