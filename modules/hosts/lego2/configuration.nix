{ inputs, self, ... }:

let
  hostname = "lego2";
in

  {
  flake.homeConfigurations = {

    "pim@lego2" = self.lib.makeHomeConf {
      inherit hostname;
      secondbrain = true;
      awscontrol = true;
      desktop = true;
    };
  };

      flake.nixosConfigurations = {

        lego2 = self.lib.makeNixosConf {
          inherit hostname;
          system = "x86_64-linux";
        };
      };

  #flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" hostname;

  flake.modules.nixos.lego2 = { config, pkgs, ... } : {
    system.stateVersion = "25.05";

    imports = with inputs.self.modules.nixos; [

      system-default

      inputs.nixos-hardware.nixosModules.framework-13-7040-amd

      hardware-keychron

      desktop-myhotkeys

      nix-cli
      nix-age
      nix-utils

      tui-tmux

      vibecoding-main
      vibecoding-utils

      virtualisation-waydroid

      db-psql

      networking-nebula

    ];

    nixos.dev.enable = true;
    nixos.full.enable = true;
    nixos.desktop.enable = true;
    nixos.virtualization.enable = true;
    nixos.bambulabs.enable = true;
    nixos.server.samba.enable = true;
    nixos.desktopHyprland.enable = true;
    nixos.nixUtils.enable = true;
    nixos.nixpkgsDev.enable = true;
    nixos.nixRemoteBuilds.enable = false;
    nixos.tex.enable = true;
    nixos.trusted.enable = true;
  };

}
