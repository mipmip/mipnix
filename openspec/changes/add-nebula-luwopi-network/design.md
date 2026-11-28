# Design

## Context

See `proposal.md` for why. The constraints that shape the approach:

- The LUWOPI network's CA is `technative-nebula-network`; mipnix's mesh CA is a
  different issuer. A host can run both, because `services.nebula.networks` is
  an attribute set and each entry gets its own `nebula@<name>` unit, service
  user and `nebula.<name>` interface.
- Arcana-one, the shared AI server, is already a member at
  `192.168.200.2` with certificate name `arcana-one`. Its own flake names the
  network `mesh`, but that name is taken in mipnix by the different trust
  domain.
- The NixOS Nebula module names the default service user and group after the
  network (`nebula-luwopi`), and the interface after it too
  (`nebula.luwopi`, 13 characters, below the kernel limit).
- Delliebellie runs the NixOS firewall with `nebula.mesh` allowances; any new
  interface starts with no host-firewall allowance.
- Secrets are agenix files under `secrets/`, listed in `secrets.nix`.

## Goals / Non-Goals

**Goals:**

- A single includable that any mipnix host imports to become a LUWOPI client.
- Per-host identity with no shared certificates.
- No inbound exposure of a member, and no effect on the mesh.
- One-time, low-risk rollout per host.

**Non-Goals:**

- Serving anything to the group from a laptop.
- A node registry or DNS for the group network. Services are addressed by IP.
- Issuing or renewing LUWOPI certificates. The group administrator owns the CA.
- A gateway that routes the home LAN into the tunnel.

## Decisions

### A new includable, not an extension of `networking-nebula`

The existing mesh module owns the `mesh` network name, pim's CA, the
`192.168.100.0/24` lighthouse registry and the mesh `/etc/hosts` entries. The
LUWOPI network shares none of those. Extending it would make every mesh host
depend on an external CA and would force one module to express two policies.

Alternative rejected: adding `192.168.200.1` to `mipnix.nebula.lighthouses`.
That was attempted before and is still visible as a commented entry in
`modules/services/networking/nebula.nix`; it cannot work because a lighthouse
validates the peer's CA.

### Network name `luwopi`

`services.nebula.networks.luwopi` gives `nebula@luwopi`, user
`nebula-luwopi` and interface `nebula.luwopi`. Keeping arcana-one's local name
`mesh` would collide with the mipnix network on every migrating host.

### Outbound-only, enforced in both layers

The Nebula internal firewall gets outbound `any/any` and an empty inbound list.
The Nebula firewall is stateful for TCP, UDP and ICMP, so replies to member-
initiated connections return without a rule, while a connection initiated by
the group is dropped. The NixOS firewall additionally opens nothing on
`nebula.luwopi`, so a service bound to `0.0.0.0` is still unreachable through
the tunnel.

Alternative rejected: copying arcana-one's inbound `any/any`. That posture fits
a server that serves the group; on a personal laptop it exposes every listening
port to every group member.

### Identity file names derived from the host name

The includable reads `nebula-luwopi-<hostname>.crt.age` and
`nebula-luwopi-<hostname>.key.age`, and the CA as `nebula-luwopi-ca.crt.age`.
A host therefore joins by importing the module and enabling it; no host-specific
paths are repeated in its configuration. The files are owned by
`nebula-luwopi`, matching the unit's default user, and encrypted to `pim`, the
member hosts only.

Alternative rejected: passing certificate paths through options. It pushes the
same three lines into every host file and invites a copy-paste of another
host's identity.

### No node registry

The group network has four known members and the only service consumed is
arcana-one at `192.168.200.2`. A registry would restate external facts that
mipnix does not control. Addresses stay in the host configuration or in the
user's notes; the includable does not add `/etc/hosts` entries.

### Peterspav gets its own certificate

Delliebellie's bundle is named `post` and carries `192.168.200.10`. Reusing it
on peterspav would create two nodes with the same identity and address, and
Nebula would treat them as one flapping peer. Peterspav needs a certificate
issued by the group administrator, stored under its own secret names.

## Risks / Trade-offs

- **Certificate expiry on 2027-09-10, with no CA key in mipnix** -> The group
  administrator must renew both member certificates. Record the date in the
  module comment so a silent failure is diagnosable.
- **The delliebellie key is currently in plaintext in `/tmp` and in a kept jj
  commit in the arcana-one repository** -> Encrypt it into `secrets/`, shred
  the temporary copy, and abandon the kept commit before anything is pushed.
- **A copy-pasted identity** -> Secret names are host-derived and the spec
  forbids sharing; review the two host files when peterspav joins.
- **Laptop sleeps or changes networks** -> Nebula re-handshakes through the
  lighthouse on its own; no static address or port forward depends on the
  laptop.

## Migration Plan

1. Encrypt the CA certificate and delliebellie's bundle into `secrets/`, add
   the entries to `secrets.nix` with recipients `pim`, `delliebellie` and
   `peterspav`.
2. Add the includable and enable it on delliebellie. Deploy and verify: the
   `nebula@luwopi` unit is active, the lighthouse at `192.168.200.1` is
   reachable, and arcana-one answers on `192.168.200.2`.
3. Once peterspav's certificate arrives, encrypt it under peterspav's secret
   names, enable the includable there and deploy.
4. Rollback: set the enable option to false and redeploy. The interface and
   unit disappear; the encrypted secrets can remain.

## Open Questions

- The group administrator assigns peterspav's certificate name and overlay
  address. The includable does not depend on either; only the secret file names
  are host-derived.
