{
  config,
  lib,
  pkgs,
  ...
}:
{

  config = lib.mkIf config.nixos.dev.enable {
    environment.systemPackages = with pkgs; [
      git-sync
      git-crypt
      pre-commit
      git-lfs
      gitFull
      bfg-repo-cleaner
      lazygit
    ];
  };
}
