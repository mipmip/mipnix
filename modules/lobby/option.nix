{ lib, options, config, inputs, ... }:
let
  root = toString inputs.self + "/";

  sourceOf = name:
    let
      positions = lib.concatMap
        (def:
          let pos = builtins.unsafeGetAttrPos name def.value;
          in lib.optional (pos != null) pos)
        options.lobby.services.definitionsWithLocations;
    in
    if positions == [ ] then null
    else
      let pos = lib.head positions;
      in "${lib.removePrefix root pos.file}:${toString pos.line}";

  services = lib.mapAttrs
    (name: s: {
      inherit (s) title description host url access category;
      source = sourceOf name;
    })
    config.lobby.services;
in
{
  options.lobby.services = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule ({ name, ... }: {
      options = {
        title = lib.mkOption { type = lib.types.str; default = name; };
        description = lib.mkOption { type = lib.types.str; };
        host = lib.mkOption { type = lib.types.str; };
        url = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        access = lib.mkOption { type = lib.types.enum [ "nebula" "lan" "public" "tunnel" "local" ]; };
        category = lib.mkOption { type = lib.types.str; };
      };
    }));
    default = { };
    description = "Registry of services shown by lobby, merged across modules.";
  };

  options.flake.lobby.json = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    description = "The lobby registry as JSON, the contract between the page and the CLI.";
  };

  config.flake.lobby.json =
    lib.replaceStrings [ "<" ] [ "\\u003c" ] (builtins.toJSON {
      generated = {
        commit = inputs.self.shortRev or inputs.self.dirtyShortRev or "dirty";
        date =
          let d = inputs.self.lastModifiedDate or "19700101000000";
          in "${builtins.substring 0 4 d}-${builtins.substring 4 2 d}-${builtins.substring 6 2 d}";
      };
      inherit services;
    });
}
