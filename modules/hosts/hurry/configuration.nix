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

      hm-nixos

      nix-cli
      nix-age

      users-core

      system-trusted-agenix

      # TUI tools for server management
      tui-security
      tui-tmux

      # Editors
      editors-vim

      # Home Manager
      hm-integration

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
