{ inputs, self, ... }:

let
  hostname = "durer";

  # Single definition of this host's restic datasets; consumed both by the backup
  # role below and (as bare repo names) by the aggregated `flake.resticRepos`. A
  # function because the DB-dump commands need `pkgs`/`config`; `builtins.attrNames`
  # never forces those values, so the registry calls it with empty args.
  datasetsFor = { pkgs, config }: {
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
    durer-studio-mint-v3 = {
      paths = [ "/var/backups/restic/studio-mint-v3.sql" "/var/lib/studio-mint-v3/uploads" ];
      keep = [ "--keep-hourly" "24" "--keep-daily" "14" "--keep-monthly" "6" ];
      prepareCommand = ''
        install -d -m 0700 /var/backups/restic
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dump studio_mint_v3 \
          > /var/backups/restic/studio-mint-v3.sql
      '';
      cleanupCommand = "rm -f /var/backups/restic/studio-mint-v3.sql";
    };
    durer-chatcms = {
      # Content is never only here: every page, picture and version of a
      # customer's site is in their own git remote. What is worth a backup is
      # who may reach what, which is the database. The working copies under
      # stateDir are clones and the thumbnails are a cache, so neither is in
      # this set; the master key is in agenix, deliberately not beside the
      # dumps, because a copy of the database is worth nothing without it and
      # the two should not be lost together.
      paths = [ "/var/backups/restic/chatcms.sql" ];
      keep = [ "--keep-hourly" "24" "--keep-daily" "14" "--keep-monthly" "6" ];
      prepareCommand = ''
        install -d -m 0700 /var/backups/restic
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dump chatcms \
          > /var/backups/restic/chatcms.sql
      '';
      cleanupCommand = "rm -f /var/backups/restic/chatcms.sql";
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
in
{
  lobby.services.tuwunel = {
    title = "Tuwunel";
    description = "Matrix homeserver";
    host = "durer";
    url = "https://nuremberg.pimsnel.com";
    access = "public";
    category = "chat";
    browse = false;
  };

  lobby.services.umami = {
    title = "umami";
    description = "Website analytics";
    host = "durer";
    url = "https://umami.pimsnel.com";
    access = "public";
    category = "websites";
  };

  lobby.services.voorzetramenshop = {
    title = "voorzetramenshop";
    description = "Webshop (v1)";
    host = "durer";
    url = "https://v1.studio-mint.shop";
    access = "public";
    category = "websites";
  };

  lobby.services.studio-mint = {
    title = "studio-mint";
    description = "studio-mint sites: apex, v2 and v3";
    host = "durer";
    url = "https://studio-mint.shop";
    access = "public";
    category = "websites";
  };

  lobby.services.pimsnel-com = {
    title = "pimsnel.com";
    description = "Personal website";
    host = "durer";
    url = "https://pimsnel.com";
    access = "public";
    category = "websites";
  };

  flake.resticRepos.durer = builtins.attrNames (datasetsFor { pkgs = { }; config = { }; });

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

    # --- Studio MINT static sites ---
    # The apex and v2 are plain HTML served from the store. The shop lives on
    # v1.studio-mint.shop, claimed by its own module further down, so these
    # three names and the shop's never collide in virtualHosts.
    services.nginx.virtualHosts."studio-mint.shop" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".studio-mint-apex;
    };

    services.nginx.virtualHosts."v2.studio-mint.shop" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".studio-mint-v2;
    };

    # Had a DNS record but no vhost before this, so it answered on the default
    # server with a certificate that does not match. ACME and TLS are needed
    # even for a redirect: the certificate is for the name redirected from.
    services.nginx.virtualHosts."www.studio-mint.shop" = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "studio-mint.shop";
    };

    # --- Quiqr ChatCMS ---
    # The front page and the application are two names on purpose. The
    # application sets cookies, so keeping it on its own name means the front
    # page shares no cookie scope with it and can be cached as hard as nginx
    # likes. They are also replaced at different rates: the front page says of
    # itself that the full website is on its way.
    age.secrets."chatcms-master-key" = {
      file = ../../../secrets/chatcms-master-key.age;
    };

    age.secrets."chatcms-smtp-password" = {
      file = ../../../secrets/chatcms-smtp-password.age;
    };

    systemd.tmpfiles.rules = [ "d /data/chatcms 0750 chatcms chatcms -" ];

    services.chatcms = {
      enable = true;
      baseUrl = "https://app.chatcms.eu";
      port = 8080;
      secretKeyFile = config.age.secrets."chatcms-master-key".path;

      # Working copies, media caches and Hugo output. Root has under 7 GB
      # free; /data has forty.
      stateDir = "/data/chatcms";

      # The first administrator is appointed at every start, which is how an
      # installation with nobody in it gets somebody. The account has to exist
      # first, so the service says it could not appoint anybody until it does.
      firstAdministrator = "post@pimsnel.com";

      mail = {
        host = "email-smtp.eu-central-1.amazonaws.com";
        port = 587;
        startTLS = true;
        from = "noreply@chatcms.eu";
        fromName = "Quiqr ChatCMS";
        username = "AKIARQP4GAZ5CQ2WQI4D";
        passwordFile = config.age.secrets."chatcms-smtp-password".path;
      };
    };

    services.nginx.virtualHosts."app.chatcms.eu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        # A picture on its way into the media library is larger than nginx
        # allows by default, and the refusal arrives as a bare 413 that says
        # nothing about what to do.
        extraConfig = "client_max_body_size 64m;";
      };
    };

    services.nginx.virtualHosts."chatcms.eu" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".chatcms-www;
    };

    services.nginx.virtualHosts."www.chatcms.eu" = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "chatcms.eu";
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
      # The module builds its vhost from this option, so the shop answers here
      # and nowhere else. The apex is served by the static site below.
      domain = "v1.studio-mint.shop";
      port = 3001;
      maintenanceMode = true;
      environmentFile = config.age.secrets."voorzetramenshop-env".path;
      # The shop pins pnpm_10 because its lockfile is v10, and current nixpkgs
      # marks pnpm-10.34.0 insecure. Its own flake builds with a bare pkgs
      # instance where that marker throws, so instantiate its package here
      # instead: this host's pkgs carries the permittedInsecurePackages entry.
      package = pkgs.callPackage "${inputs.studio-mint-v1}/nix/package.nix" {
        pnpm = pkgs.pnpm_10;
      };
    };

    # Let Auth.js derive its base URL from the (nginx-forwarded) Host header
    # instead of a pinned AUTH_URL, so logins redirect to whatever domain the
    # request came in on. Without this, a stale AUTH_URL in the env secret made
    # login bounce to the old mintshop.nuremberg.pimsnel.com host.
    # Merges with the environment set by the voorzetramenshop module.
    systemd.services.voorzetramenshop.environment.AUTH_TRUST_HOST = "true";

    age.secrets."studio-mint-v3-env" = {
      file = ../../../secrets/studio-mint-v3-env.age;
    };

    services.studio-mint-v3 = {
      enable = true;
      domain = "v3.studio-mint.shop";
      port = 3003;
      maintenanceMode = false;
      shopInbox = "post@pimsnel.com";
      environmentFile = config.age.secrets."studio-mint-v3-env".path;
    };

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
      datasets = datasetsFor { inherit pkgs config; };
    };

    imports = (with inputs.self.modules.nixos; [
      channel-default
      system-default
      role-server
      role-nebula-node

      backup-restic-piethein

      # Rendezvous for nivis-tunnel. durer is the natural host: stable public
      # IPv4, already reachable, and already a nebula lighthouse — so this is
      # the second rendezvous service on the machine.
      networking-nivis-tunnel-relay
    ]) ++ [
      inputs.studio-mint-v1.nixosModules.default
      inputs.studio-mint-v3.nixosModules.default
      inputs.chatcms.nixosModules.default
    ];
  };
}
