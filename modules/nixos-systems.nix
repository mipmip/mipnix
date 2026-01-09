{ inputs, self, ... }:
{
  flake.nixosConfigurations = {

    hurry = self.lib.makeNixos {
      hostname = "hurry";
      system = "aarch64-linux";
    };

    harry = self.lib.makeNixos {
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
