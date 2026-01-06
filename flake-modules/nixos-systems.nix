{ inputs, self, ... }:
{
  flake.nixosConfigurations = {

    lego2 = self.lib.makeNixosConf rec {
      hostname = "lego2";
      system = "x86_64-linux";
      config = {
        imports = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        ];
        environment.systemPackages = [
          inputs.myhotkeys.packages."${system}".myhotkeys
        ];
        nixos.ai.enable = true;
        nixos.dev.enable = true;
        nixos.full.enable = true;
        nixos.desktop.enable = true;
        nixos.virtualization.enable = true;
        nixos.bambulabs.enable = true;
        nixos.litellm.enable = true;
        nixos.server.samba.enable = true;
        nixos.desktopHyprland.enable = true;
        nixos.nixUtils.enable = true;
        nixos.nixpkgsDev.enable = true;
        nixos.nixRemoteBuilds.enable = false;
        nixos.tex.enable = true;
        nixos.trusted.enable = true;
        nixos.hardware.keychron.enable = false;
      };
    };

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
