## Why

The nebula mesh has a single lighthouse (`192.168.100.1` at
`vaultwarden.tools.technative.cloud`), and it is currently unreachable after a
technative network refactor — so nodes can no longer discover each other
(dapperehaan sits in an endless "Handshake timed out" loop after its reboot).
A single lighthouse is a single point of failure; durer (Hetzner, always-on,
stable public IPv4) has long been the intended second lighthouse. Adding it both
provides the wanted redundancy and is the recovery path for the current outage.

## What Changes

- Refactor the shared `networking-nebula` module from hardcoded single-lighthouse
  values to an options-driven, single-source-of-truth design:
  - New option `mipnix.nebula.lighthouses` — an attrset mapping each lighthouse's
    nebula VPN IP to its underlay endpoint (`"host:port"`). This is the one place
    to add or remove a lighthouse.
  - New option `mipnix.nebula.isLighthouse` — a per-host bool (default `false`);
    a host sets it `true` to act as a lighthouse.
- The shared module derives every per-node nebula setting from these options:
  `isLighthouse`, `lighthouses` (empty on a lighthouse, all lighthouse IPs on a
  normal node), and `staticHostMap` (all lighthouses on every node).
- Populate the registry with both lighthouses: technative `192.168.100.1` (kept
  listed while down, so it auto-rejoins once fixed) and durer `192.168.100.12`
  → `nuremberg.pimsnel.com:4242`.
- Set `mipnix.nebula.isLighthouse = true` on durer — the only per-host line change.
- All other nodes change zero lines and automatically gain durer as a second
  discovery path.

## Capabilities

### New Capabilities
- `nebula-mesh-topology`: How the nebula mesh's lighthouse set is declared once and
  each node's lighthouse role, lighthouse list, and static host map are derived
  from it — including the rule that a lighthouse advertises an empty lighthouse-hosts
  list and that every node maps all lighthouses.

### Modified Capabilities
<!-- None. `nebula-node-provisioning` covers the RUNME provisioning command, not
     runtime mesh topology, so its requirements are unchanged. -->

## Impact

- `modules/services/networking/nebula.nix` — introduces the `mipnix.nebula.*`
  options and rewrites the `networking-nebula` module to derive `isLighthouse`,
  `lighthouses`, and `staticHostMap` from them; sets the lighthouse registry.
- `modules/HOSTS/durer-server/networking.nix` — adds
  `mipnix.nebula.isLighthouse = true;`. No cert re-issue (durer already has a
  CA-signed cert at `192.168.100.12`) and UDP 4242 is already open in its firewall.
- No infra prerequisite: durer has no Hetzner Cloud Firewall, so the NixOS firewall
  is the only gate and it already allows UDP 4242.
- Out of scope: PietHein (Synology NAS) is not a mesh node (it is an SSH backup
  destination reached via proxyJump through hurry/harry) and is untouched.
- Rollout requires redeploying nodes to pick up the new registry; all nodes are
  reachable on the house LAN as a fallback, so there is no "can't push the fix over
  the broken mesh" risk.
- Related to the completed `automate-nebula-node-wiring` and
  `nebula-node-force-overwrite` changes (same nebula subsystem).
