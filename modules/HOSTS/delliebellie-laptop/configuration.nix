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
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;

    systemd.services.delliebellie-mic = {
      description = "Enable SoundWire microphones";
      wantedBy = [ "sound.target" ];
      after = [ "sound.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        amixer=${pkgs.alsa-utils}/bin/amixer
        $amixer -c sofsoundwire sset 'PGA5.0 5 Master' cap
        $amixer -c sofsoundwire sset 'rt714 ADC 22 Mux' DMIC3
        $amixer -c sofsoundwire sset 'rt714 ADC 23 Mux' DMIC4
      '';
    };

    console.keyMap = "nl";

    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
    hardware.printers.ensurePrinters = [
      {
        name = "HP_LaserJet_M201dw";
        location = "USB";
        description = "HP LaserJet Pro M201dw";
        deviceUri = "usb://HP/LaserJet%20Pro%20M201dw?serial=VNC3631411";
        model = "HP/hp-laserjet_pro_m201_m202-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    hardware.printers.ensureDefaultPrinter = "HP_LaserJet_M201dw";
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
