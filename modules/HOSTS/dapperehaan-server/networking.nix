{
...
}:
let
  hostname = "dapperehaan";
in
{

  flake.modules.nixos.networking-nebula = {...} : {
    networking.extraHosts =
      ''
        192.168.100.2 ${hostname}
      '';
  };


  flake.modules.nixos.dapperehaan = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

    age = {
      secrets = {
        "nebula-${hostname}-key" = {
          file = ../../../secrets + "/nebula-${hostname}.key.age";
          path = "/var/lib/nebula/nebula-${hostname}.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-${hostname}-cert" = {
          file = ../../../secrets + "/nebula-${hostname}.crt.age";
          path = "/var/lib/nebula/nebula-${hostname}.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
      };
    };
    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-${hostname}-cert".path;
      key = config.age.secrets."nebula-${hostname}-key".path;
    };

  };
}
