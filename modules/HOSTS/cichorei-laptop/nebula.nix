{ ... }:
{
  flake.modules.nixos.cichorei = { config, ... }: {

    age.secrets = {
      "nebula-cichorei-cert" = {
        file = ../../../secrets/nebula-cichorei.crt.age;
        path = "/var/lib/nebula/nebula-cichorei.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-cichorei-key" = {
        file = ../../../secrets/nebula-cichorei.key.age;
        path = "/var/lib/nebula/nebula-cichorei.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-cichorei-cert".path;
      key = config.age.secrets."nebula-cichorei-key".path;
    };
  };
}
