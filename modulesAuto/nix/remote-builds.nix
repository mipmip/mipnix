{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.nixRemoteBuilds.enable {

    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = true;


    nix.buildMachines = [

      {
        hostName = "ojs";
        sshUser = "remotebuild";
        sshKey = "/tmp/id_ed25519_remotebuild";
        system = pkgs.stdenv.hostPlatform.system;
        supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
      }

    ];

    environment.systemPackages = with pkgs; [

    ];
  };
}


