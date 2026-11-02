{ inputs, ... } : {
  lobby.services.samba = {
    title = "Samba";
    description = "File shares";
    host = "dapperehaan";
    url = null;
    access = "lan";
    category = "files & sync";
  };

  flake.modules.nixos.services-samba = { config, pkgs, ... }: {

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
