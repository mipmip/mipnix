{
lib,
inputs,
...
}:
let
  hostname = "harry";
in
{
  flake.modules.nixos.networking-nebula = {...} : {
    networking.extraHosts =
      ''
        192.168.100.7 ${hostname}
      '';
  }

  flake.modules.nixos.harry = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

    age = {
      secrets = {
        "nebula-harry-key" = {
          file = ../../../secrets/nebula-harry.key.age;
          path = "/var/lib/nebula/nebula-harry.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-harry-cert" = {
          file = ../../../secrets/nebula-harry.crt.age;
          path = "/var/lib/nebula/nebula-harry.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
      };
    };
    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-lego2-cert.path;
      key = config.age.secrets.nebula-lego2-key.path;
    };
  };
}
