{
...
}:

let
  hostname = "hurry";
in
{
  flake.modules.nixos.networking-nebula = {...} : {
    networking.extraHosts =
      ''
        192.168.100.6 ${hostname}
      '';
  };

  flake.modules.nixos.hurry = { config, pkgs, ... } : {

    networking.hostName = hostname;
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
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-hurry-cert.path;
      key = config.age.secrets.nebula-hurry-key.path;
    };
  };
}
