{ inputs, ... } : {
  flake.modules.nixos.desktop-virt-appimage = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      appimage-run
    ];
  };
}
