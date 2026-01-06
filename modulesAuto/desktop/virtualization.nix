{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.virtualization.enable {

    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["pim"];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd.allowedBridges = [];

    environment.systemPackages = with pkgs; [
      quickemu
    ];
  };
}


