{
lib,
inputs,
...
}:
{
  flake.modules.nixos.dapperehaan = { config, pkgs, lib, ... }: {

   fileSystems."/" = {
     device = "/dev/disk/by-label/nixos";
     fsType = "ext4";
   };

   fileSystems."/boot" = {
     device = "/dev/disk/by-label/boot";
     fsType = "ext4";
   };
   swapDevices = [
     {
       device = "/dev/disk/by-label/swap";
     }
   ];

   boot.loader.grub.enable = true;
   boot.loader.grub.device = "/dev/sda";
   boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

   system.stateVersion = "25.11";
   nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
