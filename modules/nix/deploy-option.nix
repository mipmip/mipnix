{ lib, ... }:
{
  # flake-parts treats undeclared `flake.*` outputs as `types.raw`, which
  # cannot be merged — so multiple modules each setting `flake.deploy` collide
  # ("defined multiple times"). Declaring an option with a mergeable type lets
  # every host contribute its own `flake.deploy.nodes.<name>` from its own file.
  options.flake.deploy = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.lazyAttrsOf lib.types.raw;
      options.nodes = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
      };
    };
    default = {};
    description = "deploy-rs configuration, merged across host deploy.nix files.";
  };
}
