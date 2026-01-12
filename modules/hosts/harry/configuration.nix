{ inputs, self, ... }:

let
  hostname = "harry";
in

  {
  flake.homeConfigurations = {

    "pim@harry" = self.lib.makeHomeConf {
      inherit hostname;
      server = true;
    };
  };

  flake.nixosConfigurations = {

    harry = self.lib.makeNixos {
      inherit hostname;
      system = "aarch64-linux";
    };
  };

  flake.modules.nixos.harry = { config, pkgs, ... } : {
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
      #tui-disk
      #tui-file-utils
      #tui-hardware
      #tui-help
      #tui-net
      #tui-search
      tui-security
      #tui-shell
      #tui-system
      tui-tmux

      # Editors
      editors-vim

      # Home Manager
      hm-integration

      networking-nebula

    ];

    # Additional packages for server
    environment.systemPackages = with pkgs; [
      nfs-utils
      libraspberrypi
      raspberrypi-eeprom
    ];

    # Enable SSH
    services.openssh.enable = true;

  };

}
