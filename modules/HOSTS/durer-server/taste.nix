{ ... }:
{
  # durer fronts the startaste MCP server (on dapperehaan's mesh IP) with TLS.
  # nginx + ACME are already enabled in durer's configuration.nix; this just
  # adds the vhost. Same shape as secondbrain.nix: MCP's streamable-HTTP
  # transport must not be buffered and needs a long-lived upstream read.
  #
  # Only the MCP port is published. startaste's dashboard (8421) is unauthenticated
  # and stays mesh-only — deliberately no vhost for it.
  flake.modules.nixos.durer = { ... }: {
    services.nginx.virtualHosts."taste.pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.100.2:8766";
        proxyWebsockets = true; # forces HTTP/1.1 + Upgrade/Connection headers
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          chunked_transfer_encoding off;
        '';
      };
    };
  };
}
