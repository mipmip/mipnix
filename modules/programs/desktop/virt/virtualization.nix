{ inputs, ... } : {
  flake.modules.nixos.desktop-virt-virtualization = { config, pkgs, ... }: {

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
