## Context

- `role-server` (`modules/ROLES/nixos-server.nix`) sets `programs.mosh.enable = true`.
  On NixOS this installs mosh and the SSH-launched server wrapper but does **not** open
  the firewall.
- `durer` (`modules/HOSTS/durer-server/networking.nix`) has
  `networking.firewall.enable = true` with `allowedTCPPorts = [22 80 443]` and
  `allowedUDPPorts = [4242]` (Nebula). The mosh UDP session range (60000–61000) is not
  allowed.
- `services.openssh.enable = true` (services-core), so the SSH bootstrap mosh relies on is
  present.
- durer is reachable both publicly (`nuremberg.pimsnel.com` / its public IP) and via the
  Nebula mesh (`192.168.100.12`, `role-nebula-node`, UDP 4242).
- Test target: `mosh` from the `lego2` laptop to `durer`.

## Goals / Non-Goals

**Goals:**
- A working `mosh lego2 → durer` session (SSH bootstrap + UDP session established).
- mosh client present on the laptop; mosh server reachable on `role-server` hosts.
- Open the UDP range correctly for the chosen transport path, as tightly as practical.

**Non-Goals:**
- Replacing SSH; mosh complements it.
- mosh for non-server hosts or as a service.
- Re-enabling mosh (already enabled) — this completes the networking/client side.

## Decisions

### Transport path: public vs. Nebula (drives where ports open)

mosh picks the UDP port on the server and connects to the **same address** used for the
SSH bootstrap. So the firewall must allow the mosh UDP range on whichever path is used:

- **Public path** (`mosh pim@nuremberg.pimsnel.com`): open UDP 60000–61000 on the public
  interface — widens the public attack surface (mosh is UDP, authenticated by a per-session
  key exchanged over SSH, so exposure is limited but non-zero).
- **Nebula path** (`mosh pim@192.168.100.12` / a mesh hostname): open the range only on the
  Nebula interface — no public exposure; requires the laptop to be on the mesh.

**Decision (proposed, confirm in implementation)**: prefer the **Nebula path** and open the
mosh UDP range only on the `nebula` interface via
`networking.firewall.interfaces.<nebula-if>.allowedUDPPortRanges`. Falls back to a public
opening only if mesh-only is impractical for the laptop.

**Why**: keeps the mosh UDP range off the public internet while still giving the laptop a
working session; aligns with durer already being a `role-nebula-node`.

**Alternative considered**: global `allowedUDPPortRanges = [{from=60000;to=61000;}]` —
simplest, but exposes the range publicly on durer. Acceptable as a fallback, not preferred.

### Where the firewall opening lives: role vs. host

Two placements:
- In `role-server` → every server gets the mosh range opened (matches "enable mosh on all
  servers" intent, but bakes a port policy into the shared role).
- In the host's `networking.nix` → per-host, alongside the existing `allowedUDPPorts`.

**Decision (proposed)**: open it in `role-server` (interface-scoped to nebula) so all
`role-server` hosts are consistent with the already-shared `programs.mosh.enable`. If the
nebula interface name varies per host, fall back to per-host openings.

### mosh client on the laptop

Add the `mosh` client to the laptop CLI environment (or confirm it's already pulled in).
The server-side `programs.mosh.enable` does not put a client on `lego2`.

## Risks / Trade-offs

- **[Risk] Nebula interface name** → `networking.firewall.interfaces.<name>` needs the
  actual nebula interface (e.g. `nebula.<net>` or a `tun`/`nebula1` device).
  *Mitigation*: determine the live interface name on durer before specifying; if unstable,
  use a global UDP range opening scoped to the Nebula source as a fallback.
- **[Risk] Public exposure if global open is used** → mosh UDP on the public IP.
  *Mitigation*: prefer the nebula-interface scoping; mosh sessions are authenticated by the
  SSH-exchanged key, limiting risk if public is unavoidable.
- **[Risk] Laptop not always on the mesh** → mesh-only mosh fails when off-VPN.
  *Mitigation*: acceptable for the durer test; revisit if roaming mosh is needed.

## Migration Plan

1. Determine durer's live Nebula interface name (`ip -o link` / `hyprctl`-equivalent on the
   server) and confirm `programs.mosh` does not already open the firewall.
2. Add the mosh UDP range opening (interface-scoped) and the laptop mosh client.
3. Rebuild durer (`up_machine`) and the laptop home/system as needed.
4. **Verify**: from `lego2`, run `mosh pim@<durer-mesh-or-host>` and confirm an
   interactive session establishes and survives a network blip / reconnect.

**Rollback**: remove the firewall range opening (and client) and rebuild.

## Open Questions

- Public vs. Nebula path for the laptop→durer mosh (drives interface scoping). Leaning
  Nebula; confirm the laptop is reliably on the mesh when you want mosh.
- Exact Nebula interface name on durer for `networking.firewall.interfaces.<name>`.
