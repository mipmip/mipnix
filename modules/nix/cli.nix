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

      settings = {
        extra-substituters = [
          "https://walker.cachix.org"
          "https://walker-git.cachix.org"
        ];
        extra-trusted-public-keys = [
          "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
          "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        ];
      };
    };

  };
}

