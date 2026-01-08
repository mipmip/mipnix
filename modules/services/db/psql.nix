{ inputs, ... } : {
  flake.modules.nixos.db-psql = { pkgs, ... }: {

    services.postgresql.enable = true;
  };
}


