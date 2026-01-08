{ inputs, ... } : {
  flake.modules.nixos.virtualisation-waydroid = { pkgs, ... }: {
    virtualisation.waydroid.enable = true;
  };
}



