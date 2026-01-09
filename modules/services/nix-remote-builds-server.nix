{ inputs, ... } : {
  flake.modules.nixos.services-nix-remote-builds-server = { config, pkgs, ... }: {

    users.users.remotebuild = {
      isNormalUser = true;
      createHome = false;
      group = "remotebuild";

      openssh.authorizedKeys.keyFiles = [ ../../resources/id_ed25519_remotebuild.pub ];
    };

    users.groups.remotebuild = {};

    nix = {
      nrBuildUsers = 64;
      settings = {
        trusted-users = [ "remotebuild" ];

        min-free = 10 * 1024 * 1024;
        max-free = 200 * 1024 * 1024;

        max-jobs = "auto";
        cores = 0;
      };
    };

    systemd.services.nix-daemon.serviceConfig = {
      MemoryAccounting = true;
      MemoryMax = "90%";
      OOMScoreAdjust = 500;
    };
  };
}
