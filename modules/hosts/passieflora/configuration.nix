{ inputs, self, ... }:

{
  flake.nixosConfigurations = {
    passieflora = self.lib.makeNixos {
      hostname = "passieflora";
      channel = inputs.nixpkgs-mama;
    };
  };

  flake.modules.nixos.passieflora = { config, pkgs, ... } : {
    imports = [
      ../hosts/passieflora/nix/substituter.nix
      inputs.nixos-hardware-t2.nixosModules.apple-t2
    ];
  };

}

