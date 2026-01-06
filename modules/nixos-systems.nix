{ inputs, self, ... }:
{
  flake.nixosConfigurations = {

    passieflora = self.lib.makeNixosConf {
      hostname = "passieflora";
      extraModules = [
        ../hosts/passieflora/nix/substituter.nix
        inputs.nixos-hardware-t2.nixosModules.apple-t2
      ];
    };

    hurry = self.lib.makeNixosConf {
      hostname = "hurry";
      system = "aarch64-linux";
    };

    harry = self.lib.makeNixosConf {
      hostname = "harry";
      system = "aarch64-linux";
    };

    pinephone = inputs.nixpkgs-pine64.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {
        home-manager = inputs.home-manager-pine64;
      };
      modules = [
        (import "${inputs.mobile-nixos}/lib/configuration.nix" {
          device = "pine64-pinephone";
        })
        ../hosts/pesto/default.nix
      ];
    };
  };

  flake.pinephone-img =
    self.nixosConfigurations.pinephone.config.mobile.outputs.u-boot.disk-image;
}
