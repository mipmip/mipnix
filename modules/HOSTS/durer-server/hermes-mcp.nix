{ inputs, ... }:
{
  flake.modules.nixos.durer = { ... }: {
    services.nginx.virtualHosts."hermes.pimsnel.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${inputs.self.nebulaNodes.peterspav}:8766";
        proxyWebsockets = true;
        extraConfig = ''
          allow 160.79.104.0/21;
          deny all;
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
