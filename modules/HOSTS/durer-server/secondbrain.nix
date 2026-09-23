{ ... }:
{
  # durer fronts the linny-mcp server (on dapperehaan's mesh IP) with TLS.
  # nginx + ACME are already enabled in durer's configuration.nix; this just
  # adds the vhost. SSE-safe: MCP's streamable-HTTP transport must not be
  # buffered and needs a long-lived upstream read.
  flake.modules.nixos.durer = { ... }: {
    services.nginx.virtualHosts."secondbrain.pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.100.2:8765";
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
