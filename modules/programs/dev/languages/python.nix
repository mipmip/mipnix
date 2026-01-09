{ inputs, ... } : {
  flake.modules.nixos.dev-lang-python = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      uv
      python3Minimal
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.requests
      python3Packages.numpy

    ];
  };
}
