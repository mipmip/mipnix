{
lib,
inputs,
pkgs,
...
}:
{
  flake.modules.nixos.hurry = { config, pkgs, lib, ... } : {

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    boot = {
      # No kernelPackages override: use the generic aarch64 kernel, which is
      # prebuilt on cache.nixos.org. The old linux_rpi4 vendor kernel (and the
      # nixos-hardware rpi4 module's linux-rpi) are uncached and compiled for
      # days under aarch64 emulation.
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

    hardware.enableRedistributableFirmware = true;

  };
}
