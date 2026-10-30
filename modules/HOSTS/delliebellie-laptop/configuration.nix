{ inputs, self, ... }:

let
  hostname = "delliebellie";
in

{

  # Syncthing Work pool membership. The ID is the hash of this host's
  # certificate in secrets/syncthing-delliebellie.crt.age; the two travel together.
  flake.syncthingDevices.delliebellie = "63C3AOD-PEFNTCR-FIEXK6N-YXRSWYC-NP44XH2-WPJCEBI-WZZKM5T-IHNDAQM";

  flake.homeConfigurations = {

    "pim@delliebellie" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-full
        role-pim-cli-minimal
        role-pim-desktop
      ];
    };
  };

  flake.nixosConfigurations = {

    delliebellie = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.delliebellie = { config, pkgs, ... }: {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      system-default
      channel-default

      role-devbox
      role-desktop-pim
      role-nebula-node
      system-trusted-pim
      secrets-honeybadger
      nix-github-token

      networking-wifi
      inputs.nixos-hardware.nixosModules.dell-xps-13-9315

      syncthing-work-pool

    ];

    # Member of the Work pool: /home/pim/Work is kept in step with the other
    # members over nebula. This host does NOT back the folder up; dapperehaan
    # holds the authoritative copy and is the only member that talks to piethein.
    mipnix.syncthing.pool.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;

    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;

    console.keyMap = "nl";

    services.printing.enable = true;
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.openssh.enable = true;
    nixpkgs.config.allowUnfree = true;

  };

}
