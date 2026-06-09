{ inputs, ... } : {
  flake.modules.nixos.nix-cli = { config, pkgs, ... }: {

    programs.command-not-found.enable = false;

    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      keep-failed = true
      '';
    };

  };
}

