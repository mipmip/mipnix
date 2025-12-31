{ config, inputs, system, pkgs, ... }:

{
  imports = [

    ./hardware-configuration.nix
    ../_roles/desktop.nix
    ../_roles/dev-machine.nix
    ../../modules/nix-remote-builds-server.nix
    #    ../../modules/nix-samba.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };

  networking.hostName = "ojs";
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.tailscale.enable = true;

  #Just give up and disable suspend
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';


  system.stateVersion = "22.05";
}
