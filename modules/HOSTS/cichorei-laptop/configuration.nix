{ inputs, self, ... }:

let
  hostname = "cichorei";
in

{

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
#      role-nebula-node
      system-trusted-pim

      hardware-keychron
      #networking-wifi


    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

#  time.timeZone = "Europe/Amsterdam";
#
#  i18n.defaultLocale = "nl_NL.UTF-8";
#
#  i18n.extraLocaleSettings = {
#    LC_ADDRESS = "nl_NL.UTF-8";
#    LC_IDENTIFICATION = "nl_NL.UTF-8";
#    LC_MEASUREMENT = "nl_NL.UTF-8";
#    LC_MONETARY = "nl_NL.UTF-8";
#    LC_NAME = "nl_NL.UTF-8";
#    LC_NUMERIC = "nl_NL.UTF-8";
#    LC_PAPER = "nl_NL.UTF-8";
#    LC_TELEPHONE = "nl_NL.UTF-8";
#    LC_TIME = "nl_NL.UTF-8";
#  };

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

#  services.xserver.xkb = {
#    layout = "nl";
#    variant = "us";
#  };
#
#  console.keyMap = "nl";

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
