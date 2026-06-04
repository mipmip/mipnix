{ inputs, ... }: {
  flake.modules.nixos.desktop-hw-bambu-labs = { config, lib, pkgs, ... }: {
    environment.systemPackages = [ pkgs.bambu-studio ];
  };
}
