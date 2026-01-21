{
lib,
inputs,
...
}:
{
  flake.modules.nixos.lavendel = { config, pkgs, ... } : {


    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.luks.devices."luks-8d50fc14-72ac-4381-ad29-e3fa4abf7907".device = "/dev/disk/by-uuid/8d50fc14-72ac-4381-ad29-e3fa4abf7907";

    # Set your time zone.
    time.timeZone = "Europe/Amsterdam";

    # Select internationalisation properties.
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


    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "nl";
      variant = "us";
    };

    # Configure console keymap
    console.keyMap = "nl";





    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/65a245cd-551d-49a2-b256-ad271871f151";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."luks-b05ad153-ec5d-40a8-af86-5fee0f6ab79d".device = "/dev/disk/by-uuid/b05ad153-ec5d-40a8-af86-5fee0f6ab79d";

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/2584-E8AA";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/f1d4fb7f-203f-47af-8beb-a3dad8adb62d"; }
      ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    services.power-profiles-daemon.enable = true;

    services.fwupd.enable = true;

    services.printing.enable = true;

    security.rtkit.enable = true;

    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };
}

