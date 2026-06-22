{
lib,
inputs,
...
}:
{
  flake.modules.nixos.durer = { config, pkgs, lib, ... }: {

   fileSystems."/" = {
     device = "/dev/disk/by-label/nixos";
     fsType = "ext4";
   };

   fileSystems."/boot" = {
     device = "/dev/disk/by-label/boot";
     fsType = "ext4";
   };

   # Dedicated Hetzner Volume for the umami PostgreSQL 14 container's data.
   # Created/attached via the Hetzner Cloud console (see MIGRATION.md Phase 0),
   # formatted ext4 with label "umami-data". nofail so the host still boots if
   # the volume is ever detached.
   fileSystems."/data" = {
     device = "/dev/disk/by-label/umami-data";
     fsType = "ext4";
     options = [ "nofail" ];
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
