{ ... }:
{
  flake.modules.nixos.monitoring-github-stats = { config, lib, pkgs, ... }:
    let
      user = "github-stats";
      database = "github_stats";

      fetch = pkgs.writers.writePython3Bin "github-stats-fetch" {
        libraries = with pkgs.python3Packages; [ requests psycopg ];
        flakeIgnore = [ "E501" ];
      } (builtins.readFile ./github-stats/fetch.py);

      dashboards = pkgs.linkFarm "github-stats-dashboards" [
        { name = "github-stargazers.json"; path = ./dashboards/github-stargazers.json; }
        { name = "github-items.json"; path = ./dashboards/github-items.json; }
        { name = "github-repo.json"; path = ./dashboards/github-repo.json; }
      ];
    in
    {
      age.secrets.github-stats-token.file = ../../../secrets/github-stats-token.age;

      users.groups.${user} = { };
      users.users.${user} = {
        isSystemUser = true;
        group = user;
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ database ];
        ensureUsers = [
          { name = user; }
          { name = "grafana"; }
        ];
      };

      systemd.services.postgresql-setup.script = lib.mkAfter ''
        psql -tAc 'ALTER DATABASE ${database} OWNER TO "${user}"'
      '';

      systemd.services.github-stats = {
        description = "Collect public GitHub statistics for Grafana";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" "postgresql.target" ];
        requires = [ "postgresql.target" ];
        environment = {
          GITHUB_STATS_SCHEMA = "${./github-stats/schema}";
          GITHUB_STATS_DSN = "dbname=${database} host=/run/postgresql";
        };
        serviceConfig = {
          Type = "oneshot";
          User = user;
          Group = user;
          LoadCredential = [ "github-token:${config.age.secrets.github-stats-token.path}" ];
          ExecStart = lib.getExe fetch;
        };
      };

      systemd.timers.github-stats = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      services.grafana.provision = {
        datasources.settings.datasources = [
          {
            name = "GitHub stats";
            uid = "github-stats";
            type = "grafana-postgresql-datasource";
            url = "/run/postgresql";
            user = "grafana";
            jsonData = {
              database = database;
              sslmode = "disable";
              postgresVersion = 1700;
            };
          }
        ];
        dashboards.settings.providers = [
          {
            name = "github-stats";
            folder = "GitHub";
            options.path = dashboards;
          }
        ];
      };
    };
}
