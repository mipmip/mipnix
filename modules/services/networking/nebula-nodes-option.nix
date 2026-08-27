{ lib, ... }:
{
  # Single source of truth for nebula node → overlay IP, contributed per-host from
  # each host's own file (mergeable, like `flake.deploy` in deploy-option.nix). Each
  # active node sets `flake.nebulaNodes.<name> = "192.168.100.x"` exactly once; the
  # shared nebula module derives every node's /etc/hosts entry from this, and the
  # tmux host picker (self.lib.nebulaHosts) reads it too — so a node's name/IP is
  # never restated.
  options.flake.nebulaNodes = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.str;
    default = { };
    example = { durer = "192.168.100.12"; };
    description = "Registry of nebula node name -> overlay IP, merged across hosts.";
  };
}
