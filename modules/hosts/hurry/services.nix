{
lib,
inputs,
...
}:
{
  flake.modules.nixos.hurry = { config, pkgs, ... } : {

    # Uptime Kuma
    services.uptime-kuma.enable = true;
    services.uptime-kuma.settings = {
      UPTIME_KUMA_HOST="0.0.0.0";
      UPTIME_KUMA_PORT="8080";
    };

    # Vaultwarden
    age.secrets = {
      vaultwarden = {
        file = ../../../secrets/vaultwarden.env.age;
        owner = "root";
        group = "root";
        path = "/run/secrets/vaultwarden.env";
      };
      cloudflared-json = {
        file = ../../../secrets/hurry-cloudflared-tunnel.json.age;
        owner = "cloudflared";
        group = "cloudflared";
        mode = "600";
        path = "/run/secrets/.cloudflared/cloudflared-tunnel.json";
      };
    };

    services.vaultwarden.enable = true;
    services.vaultwarden.backupDir = "/var/lib/backups/vaultwarden";
    services.vaultwarden.environmentFile = "/run/secrets/vaultwarden.env";
    services.vaultwarden.config = {
      signupsAllowed = false;
      invitationsAllowed = false;
      domain = "https://hurry.koi-ionian.ts.net";
      rocketPort = 8000;
      websocketEnabled = true;
    };

    # Cloudflared
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

  };
}
