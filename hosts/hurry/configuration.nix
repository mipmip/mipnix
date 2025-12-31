{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./cloudflared.nix
    ./vaultwarden.nix
    #./home-assistant
    #    ../../modules/base-core.nix
    # ../../modules/base-hardware.nix
    #../../modules/nix-common.nix
    #../../modules/nix-home-manager-global.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
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
      networks."japi".pskRaw = "ext:japi";
      interfaces = [ "wlan0" ];
    };
  };

  age = {
    secrets = {
      "nebula-hurry-key" = {
        file = ../../secrets/nebula-hurry.key.age;
        path = "/var/lib/nebula/nebula-hurry.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-hurry-cert" = {
        file = ../../secrets/nebula-hurry.crt.age;
        path = "/var/lib/nebula/nebula-hurry.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-ca-cert" = {
        file = ../../secrets/nebula-ca.crt.age;
        path = "/var/lib/nebula/nebula-ca.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-sshd-hostkey" = {
        file = ../../secrets/nebula-sshd-hostkey.age;
        path = "/var/lib/nebula/nebula-sshd-hostkey.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };
  };

  services.nebula.networks.mesh = {
    enable = true;
    isLighthouse = false;
    lighthouses = [ "192.168.100.1" ];
    settings = {
      cipher = "aes";
    };

    cert = config.age.secrets.nebula-hurry-cert.path;
    key = config.age.secrets.nebula-hurry-key.path;
    ca = config.age.secrets.nebula-ca-cert.path;

    staticHostMap = {
      "192.168.100.1" = [
        "3.120.251.46:4242"
        "vaultwarden.tools.technative.cloud:4242"
      ];
    };
    firewall.outbound = [
      {
        host = "any";
        port = "any";
        proto = "any";
      }
    ];
    firewall.inbound = [
      {
        host = "any";
        port = "any";
        proto = "any";
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    nebula
    home-manager
    vim
    tmux
    git
    htop
    libraspberrypi
    raspberrypi-eeprom
  ];

  services.openssh.enable = true;

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
