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
      ../hostsOld/passieflora/nix/substituter.nix
      ../hostsOld/passieflora/nix/configuration.nix

      inputs.nixos-hardware-t2.nixosModules.apple-t2
    ];
  };

}

