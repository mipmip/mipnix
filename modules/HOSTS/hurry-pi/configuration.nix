{ inputs, self, ... }:

let
  hostname = "hurry";
in



  {
  flake.homeConfigurations = {
    "pim@hurry" = self.lib.makeHomeConf {
      inherit hostname;
      system = "aarch64-linux";
      server = true;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-minimal
        role-pim-cli-full
      ];

    };
  };

  flake.nixosConfigurations = {
    hurry = self.lib.makeNixos {
      inherit hostname;
      system = "aarch64-linux";
    };
  };

  flake.modules.nixos.hurry = { config, pkgs, ... } : {
    system.stateVersion = "23.11";

    imports = with inputs.self.modules.nixos; [

      channel-default

      system-default

      role-nebula-node

      system-trusted-pim

      networking-nebula

    ];

    # Additional packages for server
    environment.systemPackages = with pkgs; [
      nebula
      libraspberrypi
      raspberrypi-eeprom
    ];

    # Enable SSH
    services.openssh.enable = true;

  };

}
