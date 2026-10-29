{ ... }:
{
  flake.modules.nixos.delliebellie = { config, ... }: {

    age.secrets = {
      "nebula-delliebellie-cert" = {
        file = ../../../secrets/nebula-delliebellie.crt.age;
        path = "/var/lib/nebula/nebula-delliebellie.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-delliebellie-key" = {
        file = ../../../secrets/nebula-delliebellie.key.age;
        path = "/var/lib/nebula/nebula-delliebellie.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-delliebellie-cert".path;
      key = config.age.secrets."nebula-delliebellie-key".path;
    };
  };
}
