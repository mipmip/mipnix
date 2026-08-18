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

    nix.settings.trusted-users = [ "root" "pim" ];

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
      domain = "studio-mint.shop";
      port = 3001;
      maintenanceMode = true;
      environmentFile = config.age.secrets."voorzetramenshop-env".path;
      # package: left at default (the flake's voorzetramenshop package)
    };

    # Let Auth.js derive its base URL from the (nginx-forwarded) Host header
    # instead of a pinned AUTH_URL, so logins redirect to whatever domain the
    # request came in on. Without this, a stale AUTH_URL in the env secret made
    # login bounce to the old mintshop.nuremberg.pimsnel.com host.
    # Merges with the environment set by the voorzetramenshop module.
    systemd.services.voorzetramenshop.environment.AUTH_TRUST_HOST = "true";

    # --- umami analytics (migrated as-is from AWS; see MIGRATION.md) ---
    # Runs the SAME container image as the old AWS host plus its OWN
    # PostgreSQL 14 container. We do NOT reuse durer's host Postgres (v17,
    # serving Matrix/webshop): umami v2.5.0 targets PG14 and its DB migrations
    # are known-broken, so a PG14->PG17 restore is not an as-is move. The two
    # containers share a private docker network "umami-net"; the DB is never
    # published to the host, so there is no clash with host PG17 on :5432.
    virtualisation.docker.enable = true;
    # Pin the oci-containers backend to docker (default is podman). This makes
    # the generated systemd units "docker-umami*.service" — matching the names
    # init-umami-net orders itself against below — and uses the docker engine
    # the AWS source ran on.
    virtualisation.oci-containers.backend = "docker";

    # One env file feeds both containers:
    #   umami-db reads POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB
    #   umami    reads DATABASE_URL / HASH_SALT / DISABLE_* flags
    # HASH_SALT is reused verbatim from the AWS container (keys sessions/data).
    age.secrets."umami-env" = {
      file = ../../../secrets/umami-env.age;
    };

    virtualisation.oci-containers.containers = {
      umami-db = {
        image = "postgres:14-alpine";
        environmentFiles = [ config.age.secrets."umami-env".path ];
        volumes = [ "/data/postgresql:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=umami-net" ];
      };
      umami = {
        image = "ghcr.io/umami-software/umami:postgresql-v2.5.0";
        environmentFiles = [ config.age.secrets."umami-env".path ];
        dependsOn = [ "umami-db" ];
        ports = [ "127.0.0.1:3002:3000" ];
        extraOptions = [ "--network=umami-net" ];
      };
    };

    # Create the private docker network before either container starts.
    systemd.services.init-umami-net = {
      description = "create umami-net docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "docker-umami-db.service" "docker-umami.service" ];
      before = [ "docker-umami-db.service" "docker-umami.service" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect umami-net >/dev/null 2>&1 \
          || ${pkgs.docker}/bin/docker network create umami-net
      '';
    };

    services.nginx.virtualHosts."umami.pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3002";
    };

    # Hourly restic backups to piethein. Databases are dumped to a file first
    # (a consistent snapshot), backed up, then the dump is removed.
    mipnix.backup.piethein = {
      enable = true;
      # durer (cloud) has no route to piethein's LAN address, so tunnel through
      # a relay Pi over nebula. hurry primary, harry failover.
      proxyJump = [ "192.168.100.6" "192.168.100.7" ];
      datasets = {
        durer-voorzetramenshop = {
          paths = [ "/var/backups/restic/voorzetramenshop.sql" ];
          keep = [ "--keep-hourly" "24" "--keep-daily" "14" "--keep-monthly" "6" ];
          prepareCommand = ''
            install -d -m 0700 /var/backups/restic
            ${pkgs.util-linux}/bin/runuser -u postgres -- \
              ${config.services.postgresql.package}/bin/pg_dump voorzetramenshop \
              > /var/backups/restic/voorzetramenshop.sql
          '';
          cleanupCommand = "rm -f /var/backups/restic/voorzetramenshop.sql";
        };
        durer-umami = {
          paths = [ "/var/backups/restic/umami.sql" ];
          keep = [ "--keep-hourly" "24" "--keep-daily" "7" ];
          # Dump from inside the container using its own POSTGRES_* env vars.
          prepareCommand = ''
            install -d -m 0700 /var/backups/restic
            ${pkgs.docker}/bin/docker exec umami-db \
              sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
              > /var/backups/restic/umami.sql
          '';
          cleanupCommand = "rm -f /var/backups/restic/umami.sql";
        };
        durer-ssh = {
          paths = [ "/home/pim/.ssh" ];
          keep = [ "--keep-hourly" "24" "--keep-daily" "7" ];
        };
      };
    };

    imports = (with inputs.self.modules.nixos; [
      channel-default
      system-default
      role-server
      role-nebula-node

      backup-restic-piethein
    ]) ++ [
      inputs.voorzetramenshop.nixosModules.default
    ];
  };
}
