---
# mipnix-ub5r
title: relay for nivis-tunnel on durer
status: completed
type: task
priority: normal
created_at: 2026-09-14T14:52:55Z
updated_at: 2026-09-14T15:33:23Z
openspec-link: openspec/changes/archive/2026-09-14-nivis-tunnel-relay-on-durer
---

Run the nivis-tunnel rendezvous relay on durer.

## Why here

durer is the natural host: a Hetzner box with a stable public IPv4, already
reachable, already deployed with deploy-rs, and already a nebula lighthouse — so
a rendezvous service is a familiar shape on that machine even if the protocol is
new.

## Summary of Changes

OpenSpec change `nivis-tunnel-relay-on-durer`, capability `nivis-tunnel-relay`.

- `nivis-tunnel` as a flake input, following mipnix nixpkgs like the others.
- `networking-nivis-tunnel-relay`, wrapping the upstream relay module. The
  upstream module defaults `openFirewall` to false on purpose; here it is turned
  on deliberately, because a relay nobody can reach is useless.
- durer imports it. Port 7843 — 80 and 443 belong to the web stack.

## Verified on the running machine

- the unit is `active` with 0 restarts, listening on `[::]:7843`
- the port answers from outside, on `nuremberg.pimsnel.com`
- **a real rendezvous over the public internet**: a local agent and a local
  client, both dialling durer, were paired; the Noise handshake completed and a
  payload round-tripped intact
- a bare TCP probe was refused with a legible reason and without logging an
  unvalidated stream id
- the deploy was additive: nginx, postgresql, docker and nebula@mesh all kept
  running, because `switch-to-configuration` restarts only units whose
  definitions changed

## What this unblocks

`nivis-tunnel-zzv6` upstream: rung 0 against a real cloud host was blocked on a
relay at a reachable address. There is now one.

## What it costs, restated

One internet-facing TCP port on the machine that also serves the shop. The relay
authenticates nobody by design, but holds no key material, cannot read what it
carries, runs as a DynamicUser with no capabilities, and refuses connections
past a parked bound rather than absorbing them.

The residual risk is upstream's `nivis-tunnel-9t50`: someone who guesses a
stream id could claim the agent role and receive a pushed closure. Until that is
addressed, ssh's own host key checking on the orchestrator side is the
mitigation.
