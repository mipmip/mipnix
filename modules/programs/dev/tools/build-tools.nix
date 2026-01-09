{ inputs, ... } : {
  flake.modules.nixos.dev-tools-build = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnumake
      gcc
      pkg-config
    ];

  };
}
