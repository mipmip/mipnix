{ inputs, ... } : {
  flake.modules.nixos.system-setup = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nebula
    ];
  };
}
