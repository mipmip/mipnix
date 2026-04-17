{lib, config, pkgs, ...}:

{

  fileSystems."/mnt/seafile" = {
    device = "192.168.178.37:/volume1/seafile";
    fsType = "nfs";
  };

  services.seafile = {
    enable = true;
    dataDir = "/mnt/seafile";
    adminEmail = "post+seafile@pimsnel.com";
    initialAdminPassword = "Ocfeacfocs";

    seafileSettings = {
      fileserver.host = "unix:/run/seafile/server.sock";
      general.enable_syslog = true;
    };
    ccnetSettings.General.SERVICE_URL = "https://seafile.notnix.com";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts.${"seafile.notnix.com"} = {
    locations."/".proxyPass = "http://unix:/run/seahub/gunicorn.sock";
    locations."/seafhttp" = {
      proxyPass = "http://unix:/run/seafile/server.sock";
      extraConfig = ''
            rewrite ^/seafhttp(.*)$ $1 break;
            client_max_body_size 0;
            proxy_connect_timeout  36000s;
            proxy_read_timeout  36000s;
            proxy_send_timeout  36000s;
            send_timeout  36000s;
            proxy_http_version 1.1;
      '';
    };
  };



}
