{
lib,
inputs,
...
}:
{
  flake.modules.nixos.cichorei = { config, pkgs, lib, ... }: {
    # Auto-imported from /etc/nixos/hardware-configuration.nix
    # Review and adjust as needed


  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Emulate aarch64 so we can build/deploy the Raspberry Pi hosts (harry, hurry)
  # from this x86_64 machine. Requires a `nixos-rebuild switch` to take effect.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9a9b595b-ffde-43f4-9d4c-8c0070ed58b7";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/423A-C0E8";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/2643c4cd-c877-4e0c-b78d-0dca065e805b"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
 
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
