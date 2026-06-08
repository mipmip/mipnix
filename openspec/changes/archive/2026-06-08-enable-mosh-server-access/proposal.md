## Why

mosh was nominally "enabled on all servers" (`programs.mosh.enable = true` in
`role-server`, commit 04c86972), but it does not actually work end-to-end: NixOS's
`programs.mosh.enable` installs the package and SSH wrapper but does **not** open the
firewall, and `durer`'s firewall (`networking.firewall.enable = true`) allows only
`tcp 22/80/443` and `udp 4242` (Nebula). mosh's UDP session range (60000–61000) is
blocked, so a `mosh lego2 → durer` connection bootstraps over SSH and then hangs.

The goal is to make mosh genuinely usable from the `lego2` laptop to the `durer` remote
(and to servers using `role-server` generally), and to verify it works rather than assume
the `enable` line was sufficient.

Related task: [mipnix-jnc9](.beans/mipnix-jnc9--server-roles-add-mosh-server.md)

## What Changes

- Open the mosh UDP port range (default 60000–61000, scoped as tightly as practical) in the
  firewall for hosts that use `role-server`, so mosh sessions can actually connect.
- Ensure the mosh **client** is available on the `lego2` laptop (and the CLI environment
  used to initiate mosh), since the server-side package alone is insufficient.
- Decide and document the transport path to `durer` — public address vs. the Nebula mesh
  (192.168.100.12) — so the firewall opening is correct for how the connection is actually
  made.
- Keep the existing `programs.mosh.enable` in `role-server`; this change completes it.

## Capabilities

### New Capabilities

- `mosh-server-access`: Servers using `role-server` accept mosh connections (SSH bootstrap
  + UDP session range reachable through the firewall), and the laptop client can establish
  a working mosh session to `durer`.

### Modified Capabilities

<!-- None: role-server already enables programs.mosh; this completes the firewall/client
     side rather than changing an existing spec's requirements. -->

## Impact

- `modules/HOSTS/durer-server/networking.nix` (and/or `role-server`): add the mosh UDP port
  range to `networking.firewall.allowedUDPPortRanges` for the relevant interface/path.
- Laptop CLI role / `lego2` config: ensure the `mosh` client package is present.
- Verification: live `mosh lego2 → durer` session test (the success criterion).
- Open question to resolve in design: open mosh UDP globally vs. only on the Nebula
  interface, depending on the chosen transport path.
