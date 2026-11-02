{ inputs, ... }:
{
  flake.modules.nixos.monitoring-grafana = { config, lib, pkgs, ... }:
    let
      meshIP = inputs.self.nebulaNodes.${config.networking.hostName};

      nodeTargets = map (name: "${name}:9100") (lib.attrNames inputs.self.nebulaNodes);

      nodeExporterFull = pkgs.fetchurl {
        name = "node-exporter-full.json";
        url = "https://grafana.com/api/dashboards/1860/revisions/46/download";
        hash = "sha256-5Y3cXcU11MkB+U2pZIvD49Wue2946Y4YW86LKJlhzqM=";
      };

      dashboards = pkgs.linkFarm "mipnix-grafana-dashboards" [
        { name = "node-exporter-full.json"; path = nodeExporterFull; }
        { name = "backups.json"; path = ./dashboards/backups.json; }
      ];
    in
    {
      age.secrets = {
        grafana-admin-password = {
          file = ../../../secrets/grafana-admin-password.age;
          owner = "grafana";
        };
        grafana-secret-key = {
          file = ../../../secrets/grafana-secret-key.age;
          owner = "grafana";
        };
      };

      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        retentionTime = "90d";
        globalConfig.scrape_interval = "30s";
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [ { targets = nodeTargets; } ];
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                regex = "(.*):9100";
                target_label = "instance";
                replacement = "$1";
              }
            ];
          }
        ];
      };

      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = meshIP;
            http_port = 3000;
          };
          security = {
            admin_user = "admin";
            admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
            secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
          };
          "auth.anonymous".enabled = false;
          analytics.reporting_enabled = false;
        };
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              uid = "prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
            }
          ];
          dashboards.settings.providers = [
            {
              name = "mipnix";
              options.path = dashboards;
            }
          ];
        };
      };

      systemd.services.grafana = {
        after = [ "nebula@mesh.service" ];
        startLimitIntervalSec = 0;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 5;
        };
      };
    };
}
