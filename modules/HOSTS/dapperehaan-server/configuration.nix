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
      system-default
      role-server
      role-devbox
      system-trusted-pim
      services-samba
    ];

    # --- Extracted from /etc/nixos/configuration.nix ---
    # Review and remove what is already covered by shared modules above


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-cd79d237-a831-4ba0-a732-db23f6680a78".device = "/dev/disk/by-uuid/cd79d237-a831-4ba0-a732-db23f6680a78";
  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "mac-iso";
  };

  users.users.pim = {
    isNormalUser = true;
    description = "Pim Snel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    tmux
    gum
  ];

  services.openssh.enable = true;

  };

}
