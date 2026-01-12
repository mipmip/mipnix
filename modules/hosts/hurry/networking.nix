{
lib,
inputs,
...
}:
{
  flake.modules.nixos.hurry = { config, pkgs, ... } : {

    networking.hostName = "hurry";
    networking.firewall.enable = false;

    # WiFi configuration
    networking.networkmanager.enable = false;
    networking.wireless = {
      secretsFile = "/run/secrets/wifi";
      enable = true;
      networks."japi".pskRaw = "ext:japi";
      interfaces = [ "wlan0" ];
    };

    age.secrets = {
      wifi = {
        file = ../../../secrets/wifi.age;
        owner = "root";
        group = "root";
        path = "/run/secrets/wifi";
      };
      "nebula-hurry-key" = {
        file = ../../../secrets/nebula-hurry.key.age;
        path = "/var/lib/nebula/nebula-hurry.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-hurry-cert" = {
        file = ../../../secrets/nebula-hurry.crt.age;
        path = "/var/lib/nebula/nebula-hurry.crt";
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

    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-hurry-cert.path;
      key = config.age.secrets.nebula-hurry-key.path;
      ca = config.age.secrets.nebula-ca-cert.path;

    };
  };
}
