{
...
}:
let
  hostname = "lavendel";
in
{
  flake.modules.nixos.networking-nebula = {...} : {
    networking.extraHosts =
      ''
        192.168.100.10 ${hostname}
      '';
  };

  flake.modules.nixos.lavendel = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

    age = {
      secrets = {
        "nebula-lavendel-key" = {
          file = ../../../secrets/nebula-lavendel.key.age;
          path = "/var/lib/nebula/nebula-lavendel.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-lavendel-cert" = {
          file = ../../../secrets/nebula-lavendel.crt.age;
          path = "/var/lib/nebula/nebula-lavendel.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
      };
    };
    networking.extraHosts =
    ''
      127.0.0.2 other-localhost
      10.0.0.1 server
    '';

    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-lavendel-cert.path;
      key = config.age.secrets.nebula-lavendel-key.path;
    };

  };
}
