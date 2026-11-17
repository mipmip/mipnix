# Design

## Context

Delliebellie currently evaluates to:

```
networking.firewall.enable = false;
networking.firewall.allowedTCPPorts = [ 22 ];
networking.firewall.allowedUDPPorts = [ 5353 ];
networking.firewall.interfaces."nebula.mesh".allowedTCPPorts = [ 9100 ];
```

The SSH and mDNS openings come from the NixOS modules themselves:
`services.openssh.openFirewall` and `services.avahi.openFirewall` both default
to `true`. The node-exporter opening is already scoped to the mesh interface.

The host is a syncthing pool member (`hub = false`). The pool sets
`listenAddresses = [ "tcp://0.0.0.0:22000" ]`, disables discovery, relays and
NAT, and addresses peers as `tcp://<hostname>:22000`. `openDefaultPorts` is
left at its default of `false`, so nothing opens 22000 today.

Delliebellie is not a lighthouse (`mipnix.nebula.isLighthouse = false`), so it
does not need inbound UDP 4242.

## Goals

- Turn the firewall on for delliebellie only.
- Keep the syncthing pool working over the mesh.
- Keep the mesh interface narrow instead of trusting it wholesale.

## Non-Goals

- Enabling the firewall on any other host.
- Restricting SSH to the mesh interface. Port 22 stays open on all interfaces,
  as it is today.
- Filtering outbound traffic.
- Changing atuin, immich, samba or any other service.

## Decisions

### Per-host firewall state

Each host declares `networking.firewall.enable` in its own `networking.nix`.
This change flips only delliebellie. A central default would touch hosts that
are out of scope and would contradict the existing host-scaffolding pattern.

### The syncthing allowance lives in the pool module

The rule belongs to the pool, not to delliebellie's host file. Membership then
implies the allowance, so the next member that enables its firewall does not
have to rediscover this. On a member with the firewall off the rule is inert.

### Interface-scoped, TCP only

The rule is `interfaces."nebula.mesh".allowedTCPPorts = [ 22000 ]`. The pool
uses `tcp://` only, so UDP 22000 and 21027 are unnecessary. Scoping the rule
to the interface keeps the service off untrusted networks, which is the point
of a mesh-only pool.

### Rejected alternatives

- `services.syncthing.openDefaultPorts = true`: opens TCP and UDP 22000 plus
  UDP 21027 on every interface, including untrusted ones.
- A rule in delliebellie's `networking.nix`: works for this host, but the next
  member that enables the firewall would break silently.
- `networking.firewall.trustedInterfaces = [ "nebula.mesh" ]`: opens every
  mesh service, which is wider than the pool needs.
- Enabling the firewall fleet-wide: out of scope; only delliebellie is asked
  for.

## Risks

- Reloading the firewall during a switch can reset established conntrack
  entries. Syncthing reconnects on its own; the folder state is unaffected.
- A service that listens on the mesh interface and is not covered by a rule
  becomes unreachable. On delliebellie that set is syncthing only; SSH and
  node-exporter are already covered.
- Future inbound mesh services need their own scoped rule. The capability spec
  makes that explicit rather than relying on a trusted interface.
