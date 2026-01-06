{ config, lib, pkgs, ... }:{

  options.nixos.server.samba.enable = lib.mkEnableOption "enable samba service";

  config = lib.mkIf config.nixos.server.samba.enable {

    services = {

      samba = {
        enable = true;

        settings.homepim = {
          path = "/home/pim";
          writable = "true";
          comment = "Just Pim!";
        };
      };

      avahi = {
        publish.enable = true;
        publish.userServices = true;
        enable = true;
      };

      samba-wsdd = {
        enable = true;
      };
    };
  };
}
