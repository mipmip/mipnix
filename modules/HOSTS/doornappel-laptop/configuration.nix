{ inputs, self, ... }:

let
  hostname = "doornappel";
in

{

  # Syncthing Work pool membership. The ID is the hash of this host's
  # certificate in secrets/syncthing-doornappel.crt.age; the two travel together.
  flake.syncthingDevices.doornappel = "KHB7YUO-3WQ3JD3-I4UWDF5-MYFXPMZ-A26YTQF-FTLG27W-TLS6MKW-OQJBPQF";

  flake.homeConfigurations = {

    "pim@doornappel" = self.lib.makeHomeConf {
      inherit hostname;
      imports = (with inputs.self.modules.homeManager; [
        role-pim-cli-full
        role-pim-cli-minimal
        role-pim-desktop
      ]) ++ [
        # Opt in to the hostname-derived wallpaper on this desktop.
        { mip.hostWallpaper.enable = true; }
      ];
    };
  };

  flake.nixosConfigurations = {

    doornappel = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.doornappel = { config, pkgs, lib, ... } : {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      system-default
      channel-default

      role-devbox
      role-desktop-pim
      role-nebula-node


      system-trusted-pim

      hardware-keychron
      #networking-wifi

      backup-restic-piethein
      syncthing-work-pool


    ];

    # Member of the Work pool: /home/pim/Work is kept in step with the other
    # members over nebula. This host does NOT back the folder up; dapperehaan
    # holds the authoritative copy and is the only member that talks to piethein.
    mipnix.syncthing.pool.enable = true;

    # --- Extracted from /etc/nixos/configuration.nix ---
    # Review and remove what is already covered by shared modules above


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ "acpi_backlight=native" ];

  networking.networkmanager.enable = true;
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Preserve VRAM across suspend/resume (installs nvidia-suspend/resume/hibernate
    # services). Without it, resume fails with "[nvidia-drm] Failed to allocate
    # NVKMS memory for GEM object" and the graphical session comes back corrupted.
    powerManagement.enable = true;
  };

  console.keyMap = "nl";

  boot.initrd.systemd.contents."/etc/vconsole.conf".source =
    lib.mkForce (pkgs.writeText "vconsole.conf" "KEYMAP=us\n");

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };
  users.users."pim" = {
    isNormalUser = true;
    description = "pim";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gum
    tmux
    git
    htop
    btop
    claude-code
  ];

  services.openssh.enable = true;

  };

}
