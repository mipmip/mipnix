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

  flake.homeConfigurations = {

    "pim@lavendel" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-full
        role-pim-cli-minimal
      ];

    };
  };

  flake.modules.nixos.lavendel = { config, pkgs, ... } : {

    imports = with inputs.self.modules.nixos; [

      system-default
      channel-annemarie

      user-annemarie
      role-desktop-annemarie
      system-trusted-annemarie

      inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel
      framework-misc
      hardware-chipsailing-fingerprint

      role-nebula-node
      networking-nebula
      networking-wifi
      desktop-apps-dtp

    ];

    console.keyMap = "nl";

    security.rtkit.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.luks.devices."luks-46b0982e-ca31-46d1-a008-497efd7b931f".device = "/dev/disk/by-uuid/46b0982e-ca31-46d1-a008-497efd7b931f";

    programs.mosh.enable = true;

    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkDefault true;

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.defaultSession = "gnome";

    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;
    services.xserver.xkb = {
      layout = "nl";
      variant = "us";
    };
    services.printing.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    system.stateVersion = "25.11";

  };

}
