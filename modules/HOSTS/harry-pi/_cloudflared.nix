{config, ...}:
{
  age.secrets = {
    json = {
      file = ../../secrets/harry-cloudflared-tunnel.json.age;
      owner = "cloudflared";
      group = "cloudflared";
      mode = "600";
      path = "/run/secrets/.cloudflared/cloudflared-tunnel.json";
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "bb0a3af1-f10f-4e9b-9637-4e48d2c1b051" = {
        credentialsFile = "/run/secrets/.cloudflared/cloudflared-tunnel.json";
        ingress = {
          "seafile.notnix.com" = "http://localhost:80";
          "matrix.notnix.com" = "http://localhost:8066";
        };
        default = "http_status:404";
      };
    };
  };
}
