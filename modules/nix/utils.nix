{ inputs, ... } : {
  flake.modules.nixos.nix-utils = { pkgs, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

  };
}





