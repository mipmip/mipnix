{
lib,
inputs,
...
}:
{
  flake.modules.nixos.peterspav = { config, pkgs, lib, ... }: {
    # Auto-imported from /etc/nixos/hardware-configuration.nix
    # Review and adjust as needed


  boot.initrd.availableKernelModules = [ "xhci_pci" "vmd" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "rtw89" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partuuid/485b2b34-aed3-4e3e-97a5-7a00be140e98";
    allowDiscards = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/27d5e57a-df27-464f-b8b0-fdc9595b5374";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/FD75-4BF1";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ { device = "/swapfile"; } ];

  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=6809600" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # RTL8852AE WiFi 6 (rtw89_8852ae) needs binary firmware from linux-firmware
  hardware.enableRedistributableFirmware = true;
  };
}
