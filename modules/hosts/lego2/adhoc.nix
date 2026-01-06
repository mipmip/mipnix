{
  flake.modules.nixos.lego2 = { config, pkgs, unstable, ... } : {

    environment.systemPackages = [
      pkgs.nebula
      unstable.beads
    ];

    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
      experimental-features = nix-command flakes
      '';
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-adbc7874-71c8-44ee-a136-ecd96de12107".device =
      "/dev/disk/by-uuid/adbc7874-71c8-44ee-a136-ecd96de12107";

    services.power-profiles-daemon.enable = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    services.fwupd.enable = true;

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.postgresql.enable = true;

    age = {
      secrets = {
        "nebula-lego2-key" = {
          file = ../../../secrets/nebula-lego2.key.age;
          path = "/var/lib/nebula/nebula-lego2.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-lego2-cert" = {
          file = ../../../secrets/nebula-lego2.crt.age;
          path = "/var/lib/nebula/nebula-lego2.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-ca-cert" = {
          file = ../../../secrets/nebula-ca.crt.age;
          path = "/var/lib/nebula/nebula-ca.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-sshd-hostkey" = {
          file = ../../../secrets/nebula-sshd-hostkey.age;
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
          "vaultwarden.tools.technative.cloud:4242"
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

    networking.hostName = "lego2";
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

    system.stateVersion = "25.05";

    virtualisation.waydroid.enable = true;
  };
}
