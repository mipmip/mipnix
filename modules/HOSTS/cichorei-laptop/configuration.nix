{ inputs, self, ... }:

let
  hostname = "cichorei";

  # Single definition of this host's restic datasets; consumed both by the backup
  # role below and (as bare repo names) by the aggregated `flake.resticRepos`.
  datasets = {
    cichorei-claude.paths = [ "/home/pim/.claude" ];
    cichorei-claude.keep = [ "--keep-hourly" "24" "--keep-daily" "7" ];

    cichorei-secondbrain.paths = [ "/home/pim/secondbrain" ];
    cichorei-secondbrain.keep = [
      "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
      "--keep-monthly" "12" "--keep-yearly" "9999"
    ];
    cichorei-documents.paths = [ "/home/pim/Documenten" "/home/pim/Afbeeldingen" ];
    cichorei-documents.keep = [
      "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
      "--keep-monthly" "12" "--keep-yearly" "9999"
    ];

    cichorei-ssh.paths = [ "/home/pim/.ssh" ];
    cichorei-ssh.keep = [ "--keep-hourly" "24" "--keep-daily" "7" ];
  };
in

{

  flake.resticRepos.cichorei = builtins.attrNames datasets;

  # Syncthing Work pool membership. The ID is the hash of this host's
  # certificate in secrets/syncthing-cichorei.crt.age; the two travel together.
  flake.syncthingDevices.cichorei = "53LSRMP-6ZRRXFG-72BW46P-ABPGGXO-5O3VL34-5GFOIMO-VISOTBZ-437T5QO";

  flake.homeConfigurations = {

    "pim@cichorei" = self.lib.makeHomeConf {
      inherit hostname;

      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-full
        role-pim-cli-minimal
        role-pim-desktop
      ];
    };
  };

  flake.nixosConfigurations = {

    cichorei = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.cichorei = { config, pkgs, ... } : {
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

    # Hourly restic backups to piethein. secondbrain is kept forever
    # (dense recent + one-per-year indefinitely); .claude/.ssh a week.
    mipnix.backup.piethein = {
      enable = true;
      inherit datasets;
    };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  users.users."janine" = {
    isNormalUser = true;
    description = "janine";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    tmux
    git
    curl
    htop
    net-tools
    gum

    libreoffice
    google-chrome
    inkscape-with-extensions
  ];
  services.openssh.enable = true;

  networking.firewall.enable = false;

  };

}
