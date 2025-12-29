{config, ...}:
{
  age.secrets = {
    vaultwarden = {
      file = ../../secrets/vaultwarden.env.age;
      owner = "root";
      group = "root";
      path = "/run/secrets/vaultwarden.env";
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


}
