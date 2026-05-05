{ inputs, self, ... }:

let
  hostname = "durer";
in
{
  flake.homeConfigurations = {

    "pim@durer" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-minimal
      ];

    };
  };

  flake.nixosConfigurations = {

    durer = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.durer = { config, pkgs, ... } : {
    system.stateVersion = "25.11";

    # --- ACME / Let's Encrypt ---
    security.acme = {
      acceptTerms = true;
      defaults.email = "pim@pimsnel.com";
      certs."nuremberg.pimsnel.com".reloadServices = [ "ergochat.service" ];
    };

    # --- Nginx (ACME webserver + health check) ---
    services.nginx = {
      enable = true;
      clientMaxBodySize = "20m";
      virtualHosts."nuremberg.pimsnel.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = ''200 "durer ok\n"'';
          extraConfig = "default_type text/plain;";
        };
        locations."/_matrix/" = {
          proxyPass = "http://localhost:6167";
        };
        locations."/.well-known/matrix/server" = {
          return = ''200 '{"m.server":"nuremberg.pimsnel.com:443"}'
          '';
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
        };
        locations."/.well-known/matrix/client" = {
          return = ''200 '{"m.homeserver":{"base_url":"https://nuremberg.pimsnel.com"}}'
          '';
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization";
          '';
        };
      };
    };

    # --- Ergo IRC ---
    services.ergochat = {
      enable = true;
      settings = {
        network.name = "pimsnel";

        server = {
          name = "nuremberg.pimsnel.com";
          listeners = {
            ":6697" = {
              tls = {
                cert = "/var/lib/acme/nuremberg.pimsnel.com/fullchain.pem";
                key = "/var/lib/acme/nuremberg.pimsnel.com/key.pem";
              };
            };
          };
        };

        accounts = {
          authentication-enabled = true;
          registration.enabled = false;
          require-sasl.enabled = false;
          multiclient = {
            enabled = true;
            always-on = "opt-out";
          };
        };

        opers = {
          pim = {
            class = "server-admin";
            password = "$2a$04$rX9dQcdIqWMioiB807Q.7ONcguneuF.2zF76QTllJuWa3DTA1Y7iK";
          };
        };

        oper-classes = {
          server-admin = {
            title = "Server Admin";
            capabilities = [
              "oper:local_kill"
              "oper:local_ban"
              "oper:local_unban"
              "chanreg"
              "accreg"
              "rehash"
              "samode"
            ];
          };
        };
      };
    };

    # --- Tuwunel Matrix ---
    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        server_name = "nuremberg.pimsnel.com";
        port = [ 6167 ];
        allow_registration = false;
        allow_encryption = true;
        allow_federation = false;
        trusted_servers = [];
      };
    };

    # Grant ergo (DynamicUser) access to ACME certs, start after cert issuance
    systemd.services.ergochat = {
      after = [ "acme-nuremberg.pimsnel.com.service" ];
      requires = [ "acme-nuremberg.pimsnel.com.service" ];
      serviceConfig.SupplementaryGroups = [ "nginx" ];
    };

    imports = with inputs.self.modules.nixos; [
      channel-default
      system-default
      role-server
      role-nebula-node
    ];
  };
}
