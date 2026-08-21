## Context

Today the shared `networking-nebula` module (`modules/services/networking/nebula.nix`,
`flake.modules.nixos.networking-nebula`, imported by every node via
`role-nebula-node`) hardcodes a single lighthouse:

```nix
isLighthouse  = false;
lighthouses   = [ "192.168.100.1" ];
staticHostMap = { "192.168.100.1" = [ "vaultwarden.tools.technative.cloud:4242" ]; };
```

That lighthouse is currently unreachable (technative network refactor), so mesh
discovery is broken — a node that has lost its cached peers (e.g. dapperehaan after
a reboot) cannot handshake anyone. durer is a node at `192.168.100.12` on Hetzner
with a stable public IPv4 behind `nuremberg.pimsnel.com`, UDP 4242 already open in
its NixOS firewall, and a CA-signed cert — making it a natural, always-on second
lighthouse.

Constraints:
- Lighthouse membership must live in one place (adding a third later should be a
  one-line edit), and non-lighthouse nodes must require no per-host bookkeeping.
- A nebula lighthouse must advertise an empty `lighthouse.hosts` list; a normal node
  must list all lighthouse VPN IPs. Every node must have a `static_host_map` entry
  for every lighthouse.
- durer has no Hetzner Cloud Firewall, so no external firewall step is needed.

## Goals / Non-Goals

**Goals:**
- Single source of truth for the lighthouse set; derive all per-node nebula wiring
  from it.
- Add durer as a second lighthouse with a single per-host line, other nodes unchanged.
- Keep the (currently down) technative lighthouse listed so it rejoins automatically.
- Correct-by-construction lighthouse behaviour (empty hosts on a lighthouse).

**Non-Goals:**
- No cert/CA changes (lighthouse-ness is config, not a certificate property).
- No changes to `new_nebula_node` provisioning automation or IP allocation.
- No auto-detection of a node's own nebula IP (explicitly rejected below).
- PietHein / the Synology NAS is not a mesh node and is out of scope.
- Lighthouse-to-lighthouse state sync (nebula does not do this by default and it is
  not needed — every node reports to both).

## Decisions

### Decision: Options-driven registry (`mipnix.nebula.lighthouses`) — "Option B"
Introduce `mipnix.nebula.lighthouses`, an attrset mapping each lighthouse's nebula
VPN IP to its underlay endpoint (`"host:port"`), and have `networking-nebula` derive:

```nix
services.nebula.networks.mesh = {
  isLighthouse  = cfg.isLighthouse;
  lighthouses   = if cfg.isLighthouse then [] else builtins.attrNames cfg.lighthouses;
  staticHostMap = builtins.mapAttrs (ip: ep: [ ep ]) cfg.lighthouses;
};
```

Adding/removing a lighthouse is a one-line edit to the registry; every node inherits
the change. _Alternative rejected:_ hardcode both lighthouses in the shared module and
override `isLighthouse`/`lighthouses` on the lighthouse host ("Option A") — faster but
duplicates the lighthouse set across places and reintroduces the self-exclusion
footgun on every future edit.

### Decision: Per-host boolean flag (`mipnix.nebula.isLighthouse`) — "B-flag"
A host becomes a lighthouse by setting `mipnix.nebula.isLighthouse = true`. Only the
1–2 lighthouse hosts touch it; the ~6 other nodes set nothing.
_Alternative rejected:_ auto-detect by comparing the node's own nebula IP against the
registry keys ("B-selfip"). That is "purer" and would let the module drop self from
the static map, but it requires every host to record its own nebula IP as a Nix value
(new per-host bookkeeping). Since lighthouses are rare, a single explicit boolean is
simpler and has no ongoing cost.

### Decision: A lighthouse keeps its own entry in `staticHostMap`
`staticHostMap` is set to all registry entries on every node, including a lighthouse's
own IP. Nebula never dials itself via the static host map, so a self-entry is a no-op.
This lets us avoid self-IP knowledge entirely; the only correctness rule that must
hold — a lighthouse's `lighthouse.hosts` is empty — is enforced by the
`if cfg.isLighthouse then []` branch.

### Decision: durer endpoint reuses `nuremberg.pimsnel.com:4242`
No new DNS record; durer's existing name already resolves to its stable Hetzner IPv4.
_Alternative considered:_ a dedicated `lighthouse.pimsnel.com` (decouples the
lighthouse from the web vhost) — deferred; can be swapped in the registry later with a
one-line edit and a redeploy, with no per-node changes.

### Decision: Keep the down technative lighthouse in the registry
Leaving `192.168.100.1` listed means nodes fail over to durer now and transparently
resume using technative once its network is fixed — no config change required at that
point.

## Risks / Trade-offs

- [Refactor changes the derived values for **every** node, so all nodes must be
  redeployed to converge] → All nodes are reachable on the house LAN (ethernet) as a
  fallback, so any node can be redeployed directly even while the mesh is degraded.
  Deploy durer first, then dapperehaan, then the rest.
- [A node only reachable over the (broken) mesh could not receive the fix] → Not
  applicable here: LAN fallback exists for every node.
- [Bad eval of the derived attrset breaks all nebula nodes at once] → Verify with
  `nix eval` on durer (lighthouse) and one normal node before deploying; the
  per-node build gate catches a malformed derivation before activation.
- [Lighthouse receives unsolicited inbound UDP that a plain node does not] → durer's
  NixOS firewall already opens UDP 4242 and there is no cloud firewall in front of it.
- [Mesh churn while nodes converge on the new lighthouse set] → Discovery is
  self-healing; already-connected nodes with live tunnels keep working and can be
  redeployed at leisure.

## Migration Plan

1. Land the config: options module + derived `networking-nebula` + registry (both
   lighthouses) + `isLighthouse = true` on durer.
2. `nix eval` verify durer and one normal node produce the expected
   `isLighthouse` / `lighthouses` / `staticHostMap`.
3. Deploy **durer first** (public) — it becomes reachable lighthouse #2.
4. Redeploy **dapperehaan** (LAN `192.168.2.22`) — confirm it re-handshakes via durer.
5. Redeploy remaining nodes (hurry-pi, harry-pi, laptops) on the LAN at leisure;
   already-connected nodes are not urgent.

Rollback: revert the two edited files and redeploy; the change is additive and leaves
certs untouched, so reverting restores the prior single-lighthouse config.

## Open Questions

- Adopt a dedicated `lighthouse.pimsnel.com` record now, or leave the deferral above?
  (Current plan: reuse `nuremberg.pimsnel.com:4242`.)
