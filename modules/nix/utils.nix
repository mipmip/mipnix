{ inputs, ... } : {
  flake.modules.nixos.nix-utils = { pkgs, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    environment.systemPackages = with pkgs; [
      nix-index
      patchelf
      nix-tree
      nix-search-tv
      inputs.verynix.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}





