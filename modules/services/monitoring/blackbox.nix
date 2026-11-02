{ ... }:
{
  flake.modules.nixos.monitoring-grafana = { config, pkgs, ... }:
    let
      port = 9115;
      targets = [
        "https://umami.pimsnel.com"
        "https://studio-mint.shop"
      ];
    in
    {
      services.prometheus.exporters.blackbox = {
        enable = true;
        listenAddress = "127.0.0.1";
        inherit port;
        configFile = (pkgs.formats.yaml { }).generate "blackbox.yml" {
          modules.http_2xx = {
            prober = "http";
            timeout = "10s";
            http = {
              preferred_ip_protocol = "ip4";
              follow_redirects = true;
              fail_if_not_ssl = true;
            };
          };
        };
      };

      services.prometheus.scrapeConfigs = [
        {
          job_name = "blackbox";
          scrape_interval = "60s";
          metrics_path = "/probe";
          params.module = [ "http_2xx" ];
          static_configs = [ { inherit targets; } ];
          relabel_configs = [
            { source_labels = [ "__address__" ]; target_label = "__param_target"; }
            { source_labels = [ "__param_target" ]; target_label = "instance"; }
            { target_label = "__address__"; replacement = "127.0.0.1:${toString port}"; }
          ];
        }
      ];
    };
}
