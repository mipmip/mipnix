{ ... }:
{
  flake.modules.nixos.monitoring-piethein-snmp = { config, pkgs, ... }:
    let
      pietheinIP = "192.168.2.100";
      exporterPort = 9116;
      modules = [ "synology" "system" "if_mib" "hrStorage" "hrDevice" "hrSystem" "ucd_system_stats" "ucd_memory" "ucd_la_table" ];

      upstreamConfig = pkgs.fetchurl {
        name = "snmp_exporter-0.30.1-snmp.yml";
        url = "https://raw.githubusercontent.com/prometheus/snmp_exporter/v0.30.1/snmp.yml";
        hash = "sha256-TgPrC4f0TBSJwrvGUVUJMcGunfj0VT4IZAyhoiucItQ=";
      };

      snmpConfig = pkgs.runCommand "piethein-snmp.yml" { nativeBuildInputs = [ pkgs.yq-go ]; } ''
        yq '{
          "auths": {
            "piethein": {
              "version": 3,
              "security_level": "authPriv",
              "username": "prometheus",
              "auth_protocol": "SHA",
              "password": "''${SNMP_PASSWORD}",
              "priv_protocol": "AES",
              "priv_password": "''${SNMP_PRIV_PASSWORD}"
            }
          },
          "modules": (.modules | pick([${builtins.concatStringsSep ", " (map (m: ''"${m}"'') modules)}]))
        }' ${upstreamConfig} > $out
      '';

      synologyDashboard = pkgs.runCommand "synology-nas-details.json" { } ''
        sed -e 's/''${DS_PROMETHEUS}/prometheus/g' \
            -e 's/''${VAR_NASDEVICES}/piethein/g' \
            ${pkgs.fetchurl {
              name = "synology-nas-details-14284.json";
              url = "https://grafana.com/api/dashboards/14284/revisions/10/download";
              hash = "sha256-6yeoeOYM0QgFp4yhZLKqubUhi80ZPJSeyKoq3FkpIGE=";
            }} > $out
      '';
    in
    {
      age.secrets.piethein-snmp.file = ../../../secrets/piethein-snmp.age;

      services.prometheus.exporters.snmp = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = exporterPort;
        configurationPath = snmpConfig;
        environmentFile = config.age.secrets.piethein-snmp.path;
        enableConfigCheck = false;
      };

      services.prometheus.scrapeConfigs = [
        {
          job_name = "piethein";
          scrape_interval = "60s";
          scrape_timeout = "50s";
          metrics_path = "/snmp";
          params = {
            auth = [ "piethein" ];
            module = [ (builtins.concatStringsSep "," modules) ];
          };
          static_configs = [ { targets = [ pietheinIP ]; } ];
          relabel_configs = [
            { source_labels = [ "__address__" ]; target_label = "__param_target"; }
            { target_label = "instance"; replacement = "piethein"; }
            { target_label = "__address__"; replacement = "127.0.0.1:${toString exporterPort}"; }
          ];
        }
      ];

      services.grafana.provision.dashboards.settings.providers = [
        {
          name = "piethein";
          options.path = pkgs.linkFarm "piethein-grafana-dashboards" [
            { name = "synology-nas-details.json"; path = synologyDashboard; }
          ];
        }
      ];
    };
}
