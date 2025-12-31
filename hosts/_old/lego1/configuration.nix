{ config, inputs, system, pkgs, peerix, ... }:

{
  imports = [
      ./hardware-configuration.nix
    #      ../_roles/desktop.nix
    #  ../_roles/dev-machine.nix
    #  ../../modules/llm-local.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
            experimental-features = nix-command flakes
    '';
  };
  services.tailscale.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  hardware.enableAllFirmware = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";

  services.fwupd.enable = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-57e3184e-15a9-4b84-9de7-ccf0fdb877eb".device = "/dev/disk/by-uuid/57e3184e-15a9-4b84-9de7-ccf0fdb877eb";
  boot.initrd.luks.devices."luks-57e3184e-15a9-4b84-9de7-ccf0fdb877eb".keyFile = "/crypto_keyfile.bin";

  # Enable networking
  networking.hostName = "lego1";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "24.05"; # Did you read the comment?
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host  all      all     ::1/128        trust
    '';
  };

  virtualisation.waydroid.enable = true;
  services.cloudflared = {
    enable = true;
    tunnels = {
      "5770d64e-ed29-4ca2-871c-2fb1c7350d37" = {
        credentialsFile = "/tmp/.cloudflared/5770d64e-ed29-4ca2-871c-2fb1c7350d37.json";
        ingress = {
          "test1.notnix.com" = "http://localhost:8001";
          "test2.notnix.com" = "http://localhost:8000";
        };
        default = "http_status:404";
      };
    };
  };

}
