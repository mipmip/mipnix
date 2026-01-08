{ inputs, self, ... }:

{
  flake.nixosConfigurations = {
    passieflora = self.lib.makeNixosConf {
      hostname = "passieflora";
    };
  };

  flake.modules.nixos.passieflora = { config, pkgs, ... } : {
    imports = [
      ../hosts/passieflora/nix/substituter.nix
      inputs.nixos-hardware-t2.nixosModules.apple-t2
    ];
  };

}

