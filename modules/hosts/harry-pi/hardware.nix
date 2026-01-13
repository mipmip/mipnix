{
lib,
inputs,
pkgs,
...
}:
{
  flake.modules.nixos.harry = { config, pkgs, lib, ... } : {

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

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

    hardware.enableRedistributableFirmware = true;

  };
}
