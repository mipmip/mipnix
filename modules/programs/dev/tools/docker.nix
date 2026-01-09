{ inputs, ... } : {
  flake.modules.nixos.dev-tools-docker = { config, pkgs, ... }: {

    virtualisation.docker.enable = true;

    environment.systemPackages = [
      pkgs.docker
      pkgs.docker-compose
    ];

  };
}
