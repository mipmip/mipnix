{ ... }:
{
  flake.modules.nixos.peterspav = { config, ... }: {

    age.secrets = {
      "nebula-peterspav-cert" = {
        file = ../../../secrets/nebula-peterspav.crt.age;
        path = "/var/lib/nebula/nebula-peterspav.crt";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
      "nebula-peterspav-key" = {
        file = ../../../secrets/nebula-peterspav.key.age;
        path = "/var/lib/nebula/nebula-peterspav.key";
        owner = "nebula-mesh";
        group = "root";
        mode = "600";
      };
    };

    services.nebula.networks.mesh = {
      cert = config.age.secrets."nebula-peterspav-cert".path;
      key = config.age.secrets."nebula-peterspav-key".path;
    };
  };
}
