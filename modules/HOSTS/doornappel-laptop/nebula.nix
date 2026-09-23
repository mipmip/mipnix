{ ... }:
{
  flake.modules.nixos.doornappel = { config, ... }: {

    age.secrets = {
      "nebula-doornappel-cert" = {
        file = ../../../secrets/nebula-doornappel.crt.age;
        path = "/var/lib/nebula/nebula-doornappel.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-doornappel-key" = {
        file = ../../../secrets/nebula-doornappel.key.age;
        path = "/var/lib/nebula/nebula-doornappel.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-doornappel-cert".path;
      key = config.age.secrets."nebula-doornappel-key".path;
    };
  };
}
