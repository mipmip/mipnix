{
...
}:
let
  hostname = "lego2";
in
{
  flake.modules.nixos.networking-nebula = {...} : {
    networking.extraHosts =
      ''
        192.168.100.5 ${hostname}
      '';
  };

  flake.modules.nixos.lego2 = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

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
      };
    };

networking.extraHosts =
  ''
    127.0.0.2 other-localhost
    10.0.0.1 server
  '';


    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-lego2-cert.path;
      key = config.age.secrets.nebula-lego2-key.path;
    };
  };
}
