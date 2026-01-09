{ inputs, ... } : {
  flake.modules.nixos.hm-nixos = { pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    environment.systemPackages = with pkgs; [
      home-manager
    ];


    home-manager.useGlobalPkgs = true;

  };
}

