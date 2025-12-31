{...}:
{
  age.secrets = {
    json = {
      file = ../../secrets/hurry-cloudflared-tunnel.json.age;
      owner = "cloudflared";
      group = "cloudflared";
      mode = "600";
      path = "/run/secrets/.cloudflared/cloudflared-tunnel.json";
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "4a8ebfc1-0f75-4971-9917-084220f37c15" = {
        credentialsFile = "/run/secrets/.cloudflared/cloudflared-tunnel.json";
        ingress = {
          "vaultwarden.notnix.com" = "http://localhost:8000";
          "home-assistant.notnix.com" = "http://localhost:8123";
        };
        default = "http_status:404";
      };
    };
  };
}
