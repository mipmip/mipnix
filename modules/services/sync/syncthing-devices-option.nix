{ lib, ... }:
{
  # Single source of truth for syncthing device name -> device ID, contributed
  # per-host from each host's own file (mergeable, like `flake.nebulaNodes` in
  # nebula-nodes-option.nix). Each pool member sets
  # `flake.syncthingDevices.<name> = "XXXXXXX-..."` exactly once, next to where it
  # enables the pool.
  #
  # A syncthing device ID is a hash of that device's TLS certificate, so every
  # member has to know every other member's ID before it ever starts. The pool
  # module derives each member's peer list from this registry: peers are the
  # registry minus the host's own name.
  #
  # It has to be a registry rather than something read back from the other hosts'
  # evaluated configuration. Reading peers out of `nixosConfigurations` would make
  # every member evaluate every other member, which is a cycle the moment two
  # members exist. This carries plain strings, so a consumer reads it without
  # forcing any system evaluation, exactly as flake.nebulaNodes and
  # flake.resticRepos do.
  options.flake.syncthingDevices = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.str;
    default = { };
    example = {
      dapperehaan = "P7VV7FB-QH3QRPH-C4PQKJB-O7UDYRP-MW6QGNY-47N353N-57C6362-Q2DTDAZ";
    };
    description = "Registry of syncthing device name -> device ID, merged across hosts.";
  };
}
