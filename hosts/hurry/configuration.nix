{ config, inputs, system, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./cloudflared.nix
    ./vaultwarden.nix
    ./home-assistant
    #    ../../modules/base-core.nix
    # ../../modules/base-hardware.nix
    #../../modules/nix-common.nix
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

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  age.secrets = {
    wifi = {
      file = ../../secrets/wifi.age;
      owner = "root";
      group = "root";
      path = "/run/secrets/wifi";
    };
  };


  networking = {
    networkmanager.enable = false;
    firewall.enable = false;
    hostName = "hurry";
    wireless = {
      secretsFile = "/run/secrets/wifi";
      enable = true;
      networks."ZyXEL11767C".pskRaw = "ext:ZyXEL11767C";
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
    cloudflared
    vim
    tmux
    git
    htop
    libraspberrypi
    cloudflared
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
