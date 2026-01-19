{ inputs, ... } : {
  flake.modules.nixos.dev-vcs-git-utils = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git-sync
      git-filter-repo
      git-crypt
      pre-commit
      git-lfs
      gitFull
      bfg-repo-cleaner
      lazygit
    ];
  };
}
