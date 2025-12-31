{ config, inputs, system, pkgs, ... }:
{

  age = {
    secrets = {
      "nebula-harry-key" = {
        file = ../../secrets/nebula-harry.key.age;
        path = "/var/lib/nebula/nebula-harry.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-harry-cert" = {
        file = ../../secrets/nebula-harry.crt.age;
        path = "/var/lib/nebula/nebula-harry.crt";
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
    };

    cert = config.age.secrets.nebula-harry-cert.path;
    key = config.age.secrets.nebula-harry-key.path;
    ca = config.age.secrets.nebula-ca-cert.path;

    staticHostMap = {
      "192.168.100.1" = [
        "3.120.251.46:4242"
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

}
