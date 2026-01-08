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

    lego2 = self.lib.makeNixosConf rec {
      inherit hostname;


      system = "x86_64-linux";

      config = {

        imports = with inputs.self.modules.nixos; [
          vibecoding-main
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
  };

}
