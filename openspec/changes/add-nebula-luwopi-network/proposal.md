# Proposal

## Why

The LUWOPI group (Luca, Wouter, Pim) runs a shared Nebula network on
`192.168.200.0/24`, administered outside this repository. The group's shared
AI server, arcana-one, is already a member at `192.168.200.2` and serves
open-webui, ollama, invokeai, twenty and kobaldai on that interface.

Pim's laptops cannot reach those services today. The mipnix mesh is a
different trust domain: its own CA, its own `192.168.100.0/24` range. Grafting
the group network into it is impossible, because the CAs and certificate
issuers differ.

## What Changes

- New includable `nebula-luwopi`, a client-only member of the LUWOPI Nebula
  network. It runs as a second `services.nebula.networks.luwopi` instance
  beside the existing mipnix `mesh`.
- The includable declares its own CA, per-host certificate and key as agenix
  secrets, owned by the network's own service user `nebula-luwopi`.
- Delliebellie joins using the certificate bundle already received from the
  group (certificate name `post`, address `192.168.200.10`).
- Peterspav joins with its own identity. A certificate for that host must be
  requested from the group administrator; the two hosts must not share one
  certificate.
- Membership is outbound-only. Members reach group services by IP. Nothing on
  a member is exposed to the group network: Nebula inbound rules are empty and
  the NixOS firewall opens no port on `nebula.luwopi`.
- The new secrets are encrypted to `pim`, `delliebellie` and `peterspav` only.
- No change to arcana-one, to the group's CA, or to the mipnix mesh.

## Capabilities

### New Capabilities

- `nebula-luwopi-network`: how a mipnix host becomes a client-only member of
  the external LUWOPI Nebula network, including identity handling, lighthouse
  discovery and the outbound-only firewall posture.

### Modified Capabilities

None. The mipnix mesh topology is untouched.

## Impact

- New file `modules/services/networking/nebula-luwopi.nix`.
- `modules/HOSTS/delliebellie-laptop/configuration.nix` and
  `modules/HOSTS/peterspav-laptop/configuration.nix` import the includable and
  enable membership.
- `secrets/secrets.nix` gains the CA certificate and one certificate/key pair
  per member.
- New encrypted files under `secrets/`.
- External dependency: a certificate for peterspav from the LUWOPI group
  administrator. Delliebellie's bundle exists and is currently sitting in
  plaintext in `/tmp/tmpnebula-pim/`.
- No ports open on either laptop. Verification is outbound: reaching the
  lighthouse at `192.168.200.1`, then arcana-one's services at
  `192.168.200.2`.
