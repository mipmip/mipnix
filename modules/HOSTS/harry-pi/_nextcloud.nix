{lib, config, pkgs, ...}:

{

  #  fileSystems."/mnt/nextcloud" = {
  #    device = "192.168.178.37:/volume1/nextcloud";
  #    fsType = "nfs";
  #    options = [ "x-systemd.automount" "noauto" ];
  #  };
  #  age.secrets = {
  #    piethein-samba-secrets = {
  #      file = ../../secrets/piethein-samba-secrets.age;
  #      path = "/run/secrets/smb-secrets";
  #    };
  #  };

  #  # For mount.cifs, required unless domain name resolution is not needed.
  #  environment.systemPackages = [ pkgs.cifs-utils ];
  #  fileSystems."/mnt/nextcloud" = {
  #    device = "//192.168.178.37/nextcloud";
  #    fsType = "cifs";
  #    options = let
  #      # this line prevents hanging on network split
  #      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #
  #    in ["${automount_opts},credentials=/run/secrets/smb-secrets,vers=1.0"];
  #  };

  #  services.rpcbind.enable = true;
  #  services.nfs.server.enable = true;
  #  services.nfs.idmapd.settings ={
  #    General = {
  #      Domain = "snelnet";
  #    };
  #    Translation = {
  #      GSS-Methods = "static,nsswitch";
  #    };
  #    Static = {
  #      "root@snelnet" = "root";
  #    };
  #  };

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
    #    extraApps = {
    #      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
    #    };
    #    extraAppsEnable = true;
  };

}
