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

    imports = with inputs.self.modules.nixos; [

      system-default
      inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel

      framework-misc
      hardware-chipsailing-fingerprint

      networking-wifi

      dev-lang-python

      desktop-myhotkeys

      granny

      hm-nixos

      nix-cli
      nix-age

      networking-nebula

      services-core
      shell-core
      user-pim
      user-annemarie
      system-trusted-annemarie
      desktop-virt-virtualization

    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-46b0982e-ca31-46d1-a008-497efd7b931f".device = "/dev/disk/by-uuid/46b0982e-ca31-46d1-a008-497efd7b931f";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Amsterdam";

    # Select internationalisation properties.
    i18n.defaultLocale = "nl_NL.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "nl_NL.UTF-8";
      LC_NUMERIC = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_TIME = "nl_NL.UTF-8";
    };

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

    users.users.pim = {
      isNormalUser = true;
      description = "pim";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      ];
    };

    system.stateVersion = "25.11"; # Did you read the comment?
    networking.useDHCP = lib.mkDefault true;
    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;


  };

}
