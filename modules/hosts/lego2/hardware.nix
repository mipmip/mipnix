{
lib,
inputs,
...
}:
{
  flake.modules.nixos.lego2 = { config, pkgs, unstable, ... } : {

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" "iwlwifi" ];
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a24708d1-ba9c-41c0-9595-a6a6d666e21b";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-48fa3b17-78c9-4b1e-a007-f7bc079bcec7".device = "/dev/disk/by-uuid/48fa3b17-78c9-4b1e-a007-f7bc079bcec7";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0F55-87BD";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/acf7f18a-5bf6-471f-b1ab-932ca73102e8"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  };
}

