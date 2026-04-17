{ inputs, self, ... }:

let
  hostname = "lego2";
in

{
  flake.nixosConfigurations = {

    lego2 = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.homeConfigurations = {

    "pim@lego2" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
        pim-with-desktop
        pim-with-secondbrain
      ];

    };
  };

  flake.modules.nixos.lego2 = { config, pkgs, ... } : {
    system.stateVersion = "25.05";

    imports = with inputs.self.modules.nixos; [

      system-default
      role-devbox
      role-desktop-pim
      system-trusted-pim

      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      hardware-keychron
      framework-fingerprint
      framework-misc
      networking-wifi

      services-samba
    ];

  };

}
