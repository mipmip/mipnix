{ inputs, ... } : {
  flake.modules.nixos.hm-nixos = { pkgs, unstable, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    environment.systemPackages = with pkgs; [
      home-manager
    ];


    home-manager.useGlobalPkgs = true;

  };
}

