{
lib,
inputs,
...
}:
{
  flake.modules.nixos.lavendel = { config, pkgs, ... } : {



    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "pinctrl_tigerlake" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/mapper/luks-dac50d22-7f60-49d2-b6b1-7c4c5f0da5f7";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."luks-dac50d22-7f60-49d2-b6b1-7c4c5f0da5f7".device = "/dev/disk/by-uuid/dac50d22-7f60-49d2-b6b1-7c4c5f0da5f7";

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/B0F2-F889";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/mapper/luks-46b0982e-ca31-46d1-a008-497efd7b931f"; }
      ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  };
}

