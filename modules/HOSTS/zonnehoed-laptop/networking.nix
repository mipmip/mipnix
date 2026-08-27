{
...
}:
let
  hostname = "zonnehoed";
in
{
  flake.nebulaNodes.zonnehoed = "192.168.100.14";

  flake.modules.nixos.zonnehoed = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

    age = {
      secrets = {
        "nebula-zonnehoed-key" = {
          file = ../../../secrets/nebula-zonnehoed.key.age;
          path = "/var/lib/nebula/nebula-zonnehoed.key";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
        "nebula-zonnehoed-cert" = {
          file = ../../../secrets/nebula-zonnehoed.crt.age;
          path = "/var/lib/nebula/nebula-zonnehoed.crt";
          owner = "nebula-mesh";
          group = "root";
          mode = "600";
        };
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-zonnehoed-cert.path;
      key = config.age.secrets.nebula-zonnehoed-key.path;
    };

  };
}
