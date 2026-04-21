{ inputs, self, ... }:

let
  hostname = "dapperehaan";
in

  {

  flake.homeConfigurations = {

    "pim@dapperehaan" = self.lib.makeHomeConf {
      inherit hostname;
    };
  };

  flake.nixosConfigurations = {

    dapperehaan = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.dapperehaan = { config, pkgs, ... } : {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      channel-default
      system-trusted-pim

      system-default
      role-server
      role-devbox
      system-trusted-pim
      services-samba
      role-nebula-node
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-cd79d237-a831-4ba0-a732-db23f6680a78".device =
      "/dev/disk/by-uuid/cd79d237-a831-4ba0-a732-db23f6680a78";
    networking.networkmanager.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "mac-iso";
    };

  };

}
