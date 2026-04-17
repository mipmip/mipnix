{ inputs, self, ... }:

let
  hostname = "hurry";
in



  {
  flake.homeConfigurations = {

    "pim@hurry" = self.lib.makeHomeConf {
      inherit hostname;
      server = true;
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

      system-default
      system-locale
      role-nebula-node

      hm-nixos

      nix-cli
      nix-age

      users-core

      system-trusted-agenix

      tui-security
      tui-tmux

      editors-vim

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
