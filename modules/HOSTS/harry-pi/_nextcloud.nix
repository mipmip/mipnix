{lib, config, pkgs, ...}:

{

  age.secrets = {
    nextcloud-admin-pass = {
      file = ../../secrets/nextcloud-admin-pw.age;
      owner = "nextcloud";
      group = "nextcloud";
      path = "/run/secrets/nextcloud-admin-pass";
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    #    home = "/var/lib/nextcloud";
    datadir = "/mnt/nextcloud";
    hostName = "harry.koi-ionian.ts.net";
    database.createLocally = true;
    config.adminpassFile = "/run/secrets/nextcloud-admin-pass";
  };

}
