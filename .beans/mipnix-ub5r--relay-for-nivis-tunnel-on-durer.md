---
# mipnix-ub5r
title: relay for nivis-tunnel on durer
status: in-progress
type: task
priority: normal
created_at: 2026-09-14T14:52:55Z
updated_at: 2026-09-14T14:52:55Z
---

Run the nivis-tunnel rendezvous relay on durer.

## Why here

durer is the natural host: a Hetzner box with a stable public IPv4, already
reachable, already deployed with deploy-rs. The relay is one outbound-idle
process that opens a single TCP port.

It is also already a nebula lighthouse, so this is the second rendezvous service
on the machine — the shape is familiar even if the protocol is not.

## What it is

nivis-tunnel reaches a machine that has no inbound port: the agent on the target
and the orchestrator both dial outward to a relay, which pairs them by stream id
and copies bytes. Noise runs end to end, so the relay holds no key material and
cannot read what it carries. That is why hosting one is cheap to reason about.

Blocks `nivis-tunnel-zzv6` upstream: rung 0 against a real cloud host needs a
relay at a reachable address, and everything after it needs rung 0.

## Scope

- `nivis-tunnel` as a flake input, following mipnix nixpkgs like the others.
- A service module wrapping `inputs.nivis-tunnel.nixosModules.relay`.
- Enabled on durer with `openFirewall`, port 7843.

## What it costs

One internet-facing TCP port on a machine that also serves the shop. The relay
authenticates nobody by design — anyone may connect and claim a stream id — but
it cannot read the traffic it carries, holds no secrets, runs as a DynamicUser
with no capabilities, and refuses connections past a parked bound rather than
absorbing them.

## Acceptance

`nc -vz durer 7843` from outside connects, and the agent on a Hetzner demo host
reaches it. The relay's own log shows the rendezvous.
