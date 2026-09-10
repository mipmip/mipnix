## Context

See proposal.md — Why. The topology is not new: `linny-mcp-hosting` already
runs this exact shape on the same two hosts, and the reference implementations
are `modules/HOSTS/dapperehaan-server/linny-mcp.nix` (hardened service on the
mesh, agenix secrets, tmpfiles, timer) and
`modules/HOSTS/durer-server/secondbrain.nix` (ACME + forceSSL vhost with
`proxy_buffering off`, `proxyWebsockets = true`, 3600s timeouts).

What differs from linny: startaste has **three** surfaces rather than one, they
share a single SQLite file, and the upstream project is Python rather than Go —
which changes how credentials arrive but not the unit shape.

## Goals / Non-Goals

**Goals:**

- Reuse the linny hosting pattern verbatim wherever it applies, so there is one
  way this host exposes an MCP server rather than two.
- Land in phases: scheduled sync is useful on its own and does not wait for the
  MCP server to exist upstream.

**Non-Goals:**

- Authentication for the dashboard. Mesh-only is the access control; adding
  session auth to a single-user tool is not worth it.
- Publishing the dashboard or the REST API from the startaste vision. Only the
  MCP endpoint gets a public hostname.
- Degraded-mode alerting. Same deferral as linny (`.beans/mipnix-2dyz`).

## Decisions

**A timer, not a daemon.** `startaste sync` already does one full pass and
exits, which is exactly a oneshot. systemd then supplies the interval,
`Restart=on-failure` with backoff, journald logging, boot persistence, and
non-overlapping runs. Writing an interval loop into the application would
duplicate all of it and still need a unit. Alternative considered: an in-app
`--interval` flag, which is only worth it for non-systemd users (docker, macOS)
and can be added later without changing anything here.

**Hourly.** HN upvotes and GitHub stars are human-rate signals; the first sync
is minutes, subsequent incremental runs are seconds. `OnUnitActiveSec = "1h"`
with `OnBootSec` to catch up after a reboot. Cheap to revise.

**Three units, not one process.** The MCP transport is ASGI in the Python SDK
while the dashboard is Flask (WSGI), so hosting both in one process needs an
adapter. Separate units on separate mesh ports avoids the adapter entirely, and
gives each surface its own restart policy and journal. They coordinate only
through the shared database file.

**8766 for MCP, 8421 for the dashboard.** linny-mcp holds 8765; taking the next
port keeps the mesh allocation readable. 8421 is startaste's own default, so the
dashboard unit needs no port override.

**Credentials as `EnvironmentFile`, not `.env`.** startaste reads `.env` from
the working directory (upstream `fix-env-file-loading`), which `ProtectHome`
makes unreachable — and a `.env` in `/nix/store` would be world-readable
anyway. One agenix file holding the three source credentials, owned by the
service user, referenced by path. Bearer tokens follow linny's `tokensFile`
convention rather than being merged into the same file, so the MCP unit does not
need the source credentials at all.

**Phase order is a real dependency, not a preference.** The upstream flake
exposes no module today, so nothing can be applied until `startaste-zrap`
lands; and a second unit reading the database is unsafe until `startaste-hq9c`
(WAL) lands. Tasks are therefore grouped so sync can go live first, with the
MCP service and the durer vhost held behind the upstream items.

## Risks / Trade-offs

- **Two upstream blockers outside this repo.** `nixosModules.startaste` and WAL
  both live in the startaste repo → phase the tasks, and treat the sync-only
  deployment as a complete, useful first landing rather than a partial one.
- **A reader during a write without WAL returns "database is locked".** The
  sync writer now holds one ~0.2s transaction per listing instead of thousands
  of tiny ones, which narrows the window but does not close it → do not enable
  the MCP or dashboard units before WAL is in place; the spec states this
  explicitly.
- **`ProtectHome` failures are opaque.** linny hit `226/NAMESPACE` when a
  `ReadWritePaths` target did not exist → create every state directory with
  `systemd.tmpfiles.rules` before the units start, as linny now does.
- **A public hostname for a single-user endpoint widens exposure.** Mitigated
  the same way as secondbrain: the service never binds publicly, durer only
  proxies `/mcp`, and the token records are hashed and agenix-encrypted. Losing
  the token exposes read access to a taste database, not to the host.
- **Port drift.** Two services on one mesh IP with hand-picked ports invites a
  future collision → the allocation is recorded in the proposal's Impact
  section so the next service on dapperehaan can see what is taken.

## Migration Plan

1. Land the upstream startaste items (`startaste-zrap`, then `startaste-hq9c`).
2. Add the flake input, overlay and module import; apply with sync only —
   verify a timer run populates `/var/lib/startaste`.
3. Once WAL is in, enable the dashboard unit and verify it over the mesh.
4. Once the MCP server exists upstream, enable that unit, add the durer vhost,
   create the DNS record, mint a token, and connect a Claude client.
5. Rollback at any phase is disabling the unit(s); the database is disposable
   and can be re-synced from the sources.

## Open Questions

- Whether the sync unit should alert on repeated failure, or whether journald is
  enough for a personal deployment. Deferred with the same reasoning as linny's
  `ntfyTopicURL` (`.beans/mipnix-2dyz`) and does not change the specs or tasks.
