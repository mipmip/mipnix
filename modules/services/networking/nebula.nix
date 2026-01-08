{ inputs, ... } : {
  flake.modules.nixos.networking-nebula = { pkgs, config, ... }: {

    environment.systemPackages = [
      pkgs.nebula
    ];

    age = {
      secrets = {
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


  };
}

