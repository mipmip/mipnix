{ inputs, self, ... }:

let
  hostname = "lavendel";
in

  {

  flake.homeConfigurations = {

    "pim@lavendel" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
      ];
    };
  };

  flake.nixosConfigurations = {

    lavendel = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.lavendel = { config, pkgs, ... } : {
    system.stateVersion = "25.05";

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;


    imports = with inputs.self.modules.nixos; [

      inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel

      framework-fingerprint
      framework-misc
      networking-wifi

      desktop-myhotkeys

      granny

      nix-cli
      nix-age

      hm-integration

      networking-nebula

    ];

  };

}
