{
  config,
  inputs,
  system,
  pkgs,
  peerix,
  ...
}:

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
  #services.tailscale.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-adbc7874-71c8-44ee-a136-ecd96de12107".device =
    "/dev/disk/by-uuid/adbc7874-71c8-44ee-a136-ecd96de12107";

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

  environment.systemPackages = with pkgs; [ nebula ];
  age = {
    secrets = {
      "nebula-lego2-key" = {
        file = ../../secrets/nebula-lego2.key.age;
        path = "/var/lib/nebula/nebula-lego2.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-lego2-cert" = {
        file = ../../secrets/nebula-lego2.crt.age;
        path = "/var/lib/nebula/nebula-lego2.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-ca-cert" = {
        file = ../../secrets/nebula-ca.crt.age;
        path = "/var/lib/nebula/nebula-ca.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-sshd-hostkey" = {
        file = ../../secrets/nebula-sshd-hostkey.age;
        path = "/var/lib/nebula/nebula-sshd-hostkey.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };
  };

  services.nebula.networks.mesh = {
    enable = true;
    isLighthouse = false;
    lighthouses = [ "192.168.100.1" ];
    settings = {
      cipher = "aes";
      sshd = {
        enabled = true;
        listen = "127.0.0.1:2222";
        host_key = config.age.secrets.nebula-sshd-hostkey.path;
        authorized_users = [
          {
            user = "pim";
            keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";
          }
        ];
      };
    };

    cert = config.age.secrets.nebula-lego2-cert.path;
    key = config.age.secrets.nebula-lego2-key.path;
    ca = config.age.secrets.nebula-ca-cert.path;

    staticHostMap = {
      "192.168.100.1" = [
        "3.120.251.46:4242"
      ];
    };
    firewall.outbound = [
      {
        host = "any";
        port = "any";
        proto = "any";
      }
    ];
    firewall.inbound = [
      {
        host = "any";
        port = "any";
        proto = "any";
      }
    ];
  };
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
