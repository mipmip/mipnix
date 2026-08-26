{ inputs, self, ... }:

let
  hostname = "zonnehoed";

  # Single definition of this host's restic datasets; consumed both by the backup
  # role below and (as bare repo names) by the aggregated `flake.resticRepos`.
  datasets = {
    zonnehoed-janine.paths = [ "/home/janine" ];
    zonnehoed-janine.keep = [
      "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
      "--keep-monthly" "12" "--keep-yearly" "9999"
    ];
  };
in

{

  flake.resticRepos.zonnehoed = builtins.attrNames datasets;

  flake.homeConfigurations = {

    "pim@zonnehoed" = self.lib.makeHomeConf {
      inherit hostname;
    };
  };

  flake.nixosConfigurations = {

    zonnehoed = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.zonnehoed = { config, pkgs, ... } : {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      system-default

      role-nebula-node
      backup-restic-piethein

    ];

    # Hourly restic backups to piethein (direct on LAN, like cichorei).
    mipnix.backup.piethein = {
      enable = true;
      inherit datasets;
    };

    # --- Extracted from /etc/nixos/configuration.nix ---
    # Review and remove what is already covered by shared modules above


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
    git
    gum
    wget
    curl
    libreoffice
    tmux
  ];

  services.openssh.enable = true;

  };

}
