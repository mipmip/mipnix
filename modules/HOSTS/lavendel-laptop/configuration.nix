{ inputs, lib, self, ... }:

let
  hostname = "lavendel";
in

  {

  flake.nixosConfigurations = {

    lavendel = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
      channel = inputs.nixpkgs-mama;
    };
  };

  flake.modules.nixos.lavendel = { config, pkgs, ... } : {

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    services.displayManager.defaultSession = "gnome";


    imports = with inputs.self.modules.nixos; [

      inputs.self.modules.nixos.nix-channels-mama
      system-default
      role-nebula-node

      inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel

      framework-misc
      hardware-chipsailing-fingerprint
      role-nebula-node
      networking-nebula

      networking-wifi

      user-annemarie
      role-desktop-annemarie
      system-trusted-annemarie

    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-46b0982e-ca31-46d1-a008-497efd7b931f".device = "/dev/disk/by-uuid/46b0982e-ca31-46d1-a008-497efd7b931f";

    # Enable networking
    networking.networkmanager.enable = true;

    services.xserver.xkb = {
      layout = "nl";
      variant = "us";
    };

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

    system.stateVersion = "25.11"; # Did you read the comment?
    networking.useDHCP = lib.mkDefault true;
    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;


  };

}
