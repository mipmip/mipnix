{ inputs, ... } : {
  flake.modules.nixos.system-luks = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      cryptsetup
    ];
  };
}
