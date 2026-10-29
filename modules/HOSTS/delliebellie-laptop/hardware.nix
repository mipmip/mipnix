{
lib,
inputs,
...
}:
{
  flake.modules.nixos.delliebellie = { config, pkgs, lib, ... }: {

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/43afc13c-1390-46d8-a554-f2a0a55462f2";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."cryptroot" = {
      device = "/dev/disk/by-uuid/d642c36c-164b-4aa3-a7f6-edd4b05a4a1a";
      allowDiscards = true;
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/8ED9-F61E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  };
}
