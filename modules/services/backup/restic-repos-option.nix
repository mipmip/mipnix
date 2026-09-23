{ lib, ... }:
{
  # Aggregated registry of restic repository names on the piethein NAS, contributed
  # per-host from each host's own `deploy.nix`-style file (mergeable, like
  # `flake.deploy` in deploy-option.nix). Each host sets
  # `flake.resticRepos.<host> = builtins.attrNames <its datasets>`, so the repo
  # names are derived from the single dataset definition — never restated.
  #
  # Consumed by the Backrest console on dapperehaan to generate its repo list. Reads
  # only these plain string lists, so no full-system evaluation and no `inputs.self`
  # recursion.
  options.flake.resticRepos = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.listOf lib.types.str);
    default = { };
    description = ''
      Per-host list of restic repository names under /ResticBackups on piethein,
      aggregated across hosts for consumers such as the Backrest restore console.
    '';
  };
}
