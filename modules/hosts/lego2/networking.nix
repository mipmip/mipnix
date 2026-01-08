{
lib,
inputs,
...
}:
{
  flake.modules.nixos.lego2 = { config, pkgs, ... } : {

    networking.hostName = "lego2";
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

    services.nebula.networks.mesh = {
      cert = config.age.secrets.nebula-lego2-cert.path;
      key = config.age.secrets.nebula-lego2-key.path;
    };
  };
}
