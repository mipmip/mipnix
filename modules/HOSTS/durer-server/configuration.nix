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
        role-pim-cli-server-dev
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

    # --- Remote deployment (deploy-rs builds on lego2, copies the closure) ---
    # deploy-rs pushes via ssh-ng into durer's nix daemon. The closure is built
    # on lego2 and is unsigned; durer's default trusted-users is `root` only, so
    # `pim` would be rejected with "lacks a signature by a trusted key". Trusting
    # pim lets the push land. See modules/HOSTS/durer-server/deploy.nix.
    nix.settings.trusted-users = [ "root" "pim" ];

    # durer is a 30 GB VM. Bound the disk by capping retained generations and
    # collecting old ones on a timer. GC must NOT run as part of a deploy: the
    # previous generation has to survive deploy-rs's magic-rollback window.
    boot.loader.grub.configurationLimit = 10;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

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

    # --- pimsnel.com website ---
    services.nginx.virtualHosts."pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".pimsnel-website;
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

    # --- voorzetramenshop webshop ---
    # Secret decrypted by durer's host key at activation; systemd reads it as
    # root via EnvironmentFile= before dropping to the service's DynamicUser,
    # so agenix defaults (root:root, 0400) suffice for both the app and the
    # migrate oneshot. See secrets/secrets.nix for recipients [ pim durer ].
    age.secrets."voorzetramenshop-env" = {
      file = ../../../secrets/voorzetramenshop-env.age;
    };

    services.voorzetramenshop = {
      enable = true;
      domain = "mintshop.nuremberg.pimsnel.com";
      port = 3001;
      maintenanceMode = true;
      environmentFile = config.age.secrets."voorzetramenshop-env".path;
      # package: left at default (the flake's voorzetramenshop package)
    };

    imports = (with inputs.self.modules.nixos; [
      channel-default
      system-default
      role-server
      role-nebula-node
    ]) ++ [
      inputs.voorzetramenshop.nixosModules.default
    ];
  };
}
