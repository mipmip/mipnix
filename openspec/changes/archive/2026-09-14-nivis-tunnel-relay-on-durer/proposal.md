# nivis-tunnel relay on durer

Implements bean [`mipnix-ub5r`](.beans/mipnix-ub5r--relay-for-nivis-tunnel-on-durer.md).

## Why

`nivis-tunnel` reaches a machine that has no inbound port: the agent on the
target and the orchestrator both dial outward to a relay, which pairs them by
stream id and copies bytes. Nothing can happen without a relay somewhere
reachable, and there is no relay yet.

durer is the natural host. It has a stable public IPv4 on Hetzner, it is already
reachable, it is already deployed with deploy-rs, and it is already a nebula
lighthouse — so a rendezvous service is a familiar shape on that machine even if
the protocol is new.

## What Changes

- `nivis-tunnel` as a flake input, following mipnix nixpkgs like every other
  input here.
- `networking-nivis-tunnel-relay`, a thin wrapper over the upstream relay module
  that turns it on and opens the port.
- durer imports it. Port 7843; 80 and 443 are the web stack's.

## What it costs, stated plainly

One internet-facing TCP port on a machine that also serves the shop.

The relay **authenticates nobody**, by design: anyone who can reach it may
connect and claim a stream id. What it cannot do is more interesting than what
it can. Noise runs end to end between agent and orchestrator, so the relay holds
no key material and cannot read what it carries. It runs as a `DynamicUser` with
an empty capability set and a read-only filesystem. It refuses connections past
a parked bound rather than absorbing them, and releases parties whose
counterpart never arrives.

The residual risk is that someone who guesses a stream id could claim the agent
role for it and receive a pushed closure. That is upstream's
`nivis-tunnel-9t50`, and until it is addressed the mitigation is ssh's own host
key checking on the orchestrator side.

## What deploying this does to durer

Adds one systemd unit and one firewall port. `switch-to-configuration` restarts
only units whose definitions changed, so the shop, postgres, docker and nebula
are untouched. `makeDeployNode` sets `magicRollback = true`, so a deploy that
made durer unreachable would revert itself.

## Capabilities

### New Capabilities

- `nivis-tunnel-relay`: durer serves rendezvous for nivis-tunnel.

## Impact

- `flake.nix`, one new module, three lines in durer's imports.
- durer gains a service and an open port; nothing else on it changes.
