{
lib,
inputs,
...
}:
{
  flake.modules.nixos.dapperehaan = { config, pkgs, lib, ... }: {
    # Auto-imported from /etc/nixos/hardware-configuration.nix
    # Review and adjust as needed


  boot.initrd.availableKernelModules = [ "ohci_pci" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/luks-438fe8c0-7dc4-4d91-a63a-dd5e03274cac";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-438fe8c0-7dc4-4d91-a63a-dd5e03274cac".device = "/dev/disk/by-uuid/438fe8c0-7dc4-4d91-a63a-dd5e03274cac";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B8BC-BA64";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/mapper/luks-cd79d237-a831-4ba0-a732-db23f6680a78"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
