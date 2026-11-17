# Proposal

## Why

A CISO requirement asks for the host firewall to be on. Delliebellie is the
only host in scope, so the other hosts keep their current state.

Delliebellie is a member of the syncthing Work pool. That pool is mesh-only and
needs inbound TCP 22000 from its peers. The pool currently works because the
firewall is off, so enabling the firewall without a rule would stop syncing
without any error on the host.

## What Changes

- `modules/HOSTS/delliebellie-laptop/networking.nix` sets
  `networking.firewall.enable = true`.
- `modules/services/sync/syncthing-pool.nix` allows TCP 22000 on the
  `nebula.mesh` interface for every pool member. The rule is inert on members
  whose firewall stays off.
- No other host changes its firewall state.

## Capabilities

### New Capabilities

- `host-firewall`: a host can run the NixOS firewall without losing the
  services that listen on the mesh interface, and the state is declared per
  host.

### Modified Capabilities

- `syncthing-work-pool`: the pool carries its own mesh-interface allowance, so
  a member that enables the host firewall keeps syncing.

## Impact

- `modules/HOSTS/delliebellie-laptop/networking.nix` and
  `modules/services/sync/syncthing-pool.nix`.
- Delliebellie only for the firewall state. Every pool member gains an inert
  rule on `nebula.mesh`.
- SSH (22/TCP), mDNS (5353/UDP) and node-exporter (9100/TCP on `nebula.mesh`)
  are already opened, so they need no edit.
- Rollout: `rme up_machine` on delliebellie, then confirm that syncthing has
  established peer connections.
