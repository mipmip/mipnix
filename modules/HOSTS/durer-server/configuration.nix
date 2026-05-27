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

    # --- Bluesky PDS ---
    services.bluesky-pds = {
      enable = true;
      settings = {
        PDS_HOSTNAME = "pimsnel.com";
      };
      environmentFiles = [
        config.age.secrets."personal-data-server-env".path
      ];
    };

    age.secrets."personal-data-server-env" = {
      file = ../../../secrets/personal-data-server.env.age;
      owner = "pds";
      group = "pds";
      mode = "400";
    };

    # --- pimsnel.com website + PDS proxy ---
    services.nginx.virtualHosts."pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".pimsnel-website;

      locations."/xrpc/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100m;
        '';
      };
      locations."/.well-known/atproto-did" = {
        proxyPass = "http://localhost:3000";
      };
    };

    # --- Tuwunel Matrix ---
    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        server_name = "nuremberg.pimsnel.com";
        port = [ 6167 ];
        allow_registration = false;
        #registration_token = "tmpregister2026";
        allow_encryption = true;
        allow_federation = false;
        trusted_servers = [];
      };
    };

    imports = with inputs.self.modules.nixos; [
      channel-default
      system-default
      role-server
      role-nebula-node
    ];
  };
}
