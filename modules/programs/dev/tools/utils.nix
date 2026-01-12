{ inputs, ... } : {
  flake.modules.nixos.dev-tools-utils = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      glow
      delta
    ];
  };
}
