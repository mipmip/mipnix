{ inputs, ... } : {
  flake.modules.nixos.nix-cli = { config, pkgs, ... }: {


    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
      experimental-features = nix-command flakes
      '';
    };

  };
}

