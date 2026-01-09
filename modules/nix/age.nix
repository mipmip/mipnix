{ inputs, ... } : {
  flake.modules.nixos.nix-age = { pkgs, ... }: {

    environment.systemPackages = [
      inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];

    imports = [
      inputs.agenix.nixosModules.default

    ];

  };
}





