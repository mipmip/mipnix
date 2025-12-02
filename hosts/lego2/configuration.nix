{ config, inputs, system, pkgs, peerix, ... }:

{
  imports = [
      ./hardware-configuration.nix
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

  boot.initrd.luks.devices."luks-adbc7874-71c8-44ee-a136-ecd96de12107".device = "/dev/disk/by-uuid/adbc7874-71c8-44ee-a136-ecd96de12107";

  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #hardware.enableAllFirmware = true;

  #boot.initrd.systemd.enable = true;
  #boot.initrd.verbose = false;

  services.power-profiles-daemon.enable = true;

  #boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #boot.plymouth.enable = true;
  #boot.plymouth.theme = "breeze";

  services.fwupd.enable = true;
  programs.cdemu.enable = true;

  # Enable CUPS to print documents.

  #  services.grafana = {
  #    enable = true;
  #    settings = {
  #      server = {
  #        # Listening Address
  #        http_addr = "127.0.0.1";
  #        # and Port
  #        http_port = 3000;
  #        # Grafana needs to know on which domain and URL it's running
  #        domain = "localhost";
  #        root_url = "http://localhost/"; # Not needed if it is `https://your.domain/`
  #        serve_from_sub_path = false;
  #      };
  #    };
  #  };

  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.postgresql.enable = true;

  #  services.hydra = {
  #    enable = true;
  #    hydraURL = "http://localhost:3000";
  #    notificationSender = "hydra@localhost";
  #    buildMachinesFiles = [];
  #    useSubstitutes = true;
  #    extraConfig = ''
  #      <dynamicruncommand>
  #        enable = 1
  #      </dynamicruncommand>
  #      <git-input>
  #        timeout = 3600
  #      </git-input>
  #    '';
  #  };

  #   services.grafana = {
  #     enable = true;
  #     settings = {
  #
  # # In your custom.ini file
  #
  #       feature_toggles = {
  #         provisioning = true;
  #         #kubernetesClientDashboardsFolders = true
  #         #kubernetesDashboards = true ; use k8s from browser
  #
  #       };
  #
  #       # If you want easy kubectl setup development mode
  #       #grafanaAPIServerEnsureKubectlAccess = true
  #
  #       server = {
  #         # Listening Address
  #         http_addr = "127.0.0.1";
  #         # and Port
  #         http_port = 3004;
  #         # Grafana needs to know on which domain and URL it's running
  #         domain = "your.domain";
  #       };
  #     };
  #   };

  # Enable networking
  networking.hostName = "lego2";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?

  virtualisation.waydroid.enable = true;
#  services.cloudflared = {
#    enable = true;
#    tunnels = {
#      "5770d64e-ed29-4ca2-871c-2fb1c7350d37" = {
#        credentialsFile = "/tmp/.cloudflared/5770d64e-ed29-4ca2-871c-2fb1c7350d37.json";
#        ingress = {
#          "test1.notnix.com" = "http://localhost:8001";
#          "test2.notnix.com" = "http://localhost:8000";
#        };
#        default = "http_status:404";
#      };
#    };
#  };

}
