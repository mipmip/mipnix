{ inputs, ... }:
{
  flake.modules.nixos.nebula-luwopi =
    { config, lib, ... }:
    let
      cfg = config.mipnix.nebula.luwopi;
      host = config.networking.hostName;
    in
    {
      options.mipnix.nebula.luwopi.enable =
        lib.mkEnableOption "membership of the LUWOPI group nebula network";

      config = lib.mkIf cfg.enable {
        # The group CA and this host's certificate are issued outside this
        # repository by the LUWOPI group administrator. Certificates expire on
        # 2027-09-10; the CA key is not here, so renewal is theirs to perform.
        age.secrets = {
          "nebula-luwopi-ca-cert" = {
            file = ../../../secrets/nebula-luwopi-ca.crt.age;
            path = "/var/lib/nebula/nebula-luwopi-ca.crt";
            owner = "nebula-luwopi";
            group = "nebula-luwopi";
            mode = "600";
          };
          "nebula-luwopi-${host}-cert" = {
            file = ../../../secrets + "/nebula-luwopi-${host}.crt.age";
            path = "/var/lib/nebula/nebula-luwopi-${host}.crt";
            owner = "nebula-luwopi";
            group = "nebula-luwopi";
            mode = "600";
          };
          "nebula-luwopi-${host}-key" = {
            file = ../../../secrets + "/nebula-luwopi-${host}.key.age";
            path = "/var/lib/nebula/nebula-luwopi-${host}.key";
            owner = "nebula-luwopi";
            group = "nebula-luwopi";
            mode = "600";
          };
        };

        services.nebula.networks.luwopi = {
          enable = true;

          ca = config.age.secrets."nebula-luwopi-ca-cert".path;
          cert = config.age.secrets."nebula-luwopi-${host}-cert".path;
          key = config.age.secrets."nebula-luwopi-${host}-key".path;

          isLighthouse = false;
          lighthouses = [ "192.168.200.1" ];
          staticHostMap."192.168.200.1" = [ "54.93.81.45:4242" ];

          firewall = {
            outbound = [
              {
                host = "any";
                port = "any";
                proto = "any";
              }
            ];
            inbound = [ ];
          };
        };
      };
    };
}
