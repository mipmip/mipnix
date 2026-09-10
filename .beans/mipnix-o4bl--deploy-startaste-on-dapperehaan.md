---
# mipnix-o4bl
title: deploy startaste on dapperehaan
status: completed
type: task
priority: normal
created_at: 2026-09-10T15:07:53Z
updated_at: 2026-09-10T22:31:10Z
openspec-link: openspec/changes/archive/2026-09-10-deploy-startaste-mcp
---

Run startaste (`github.com/mipmip/startaste`) on dapperehaan: scheduled syncing
of HN upvotes and GitHub stars, an MCP endpoint for Claude Online/Mobile, and
the dashboard reachable over the mesh only.

Three surfaces, one SQLite database under `/var/lib/startaste`:

- **sync** — `Type=oneshot` unit plus a `systemd.timer`. `startaste sync` is
  already the perfect oneshot, so no daemon loop belongs in the application;
  systemd supplies the interval, backoff, journald logging and refusal to start
  an overlapping run. Same shape as `systemd.timers.git-sync-secondbrain` in
  `modules/HOSTS/dapperehaan-server/linny-mcp.nix`.
- **MCP** — `https://taste.pimsnel.com/mcp`, TLS on durer, reverse proxied over
  nebula. Reuses the whole `linny-mcp-hosting` pattern: mesh-only bind,
  unauthenticated `/healthz`, `Authorization: Bearer` with hashed token records
  from agenix, and an SSE-safe vhost (`proxy_buffering off`, HTTP/1.1, long
  read timeout).
- **dashboard** — mesh only, no public vhost. It has no authentication of any
  kind (`app.run(host="127.0.0.1")`), so nebula is the access control.

Blocked on upstream startaste work, tracked in its own repo:

- `startaste-zrap` — the flake exposes only `packages` and `devShells`; it needs
  `nixosModules.startaste` + `overlays.default` before any host can import it
- `startaste-hq9c` — SQLite is in `journal_mode = delete` with no pragmas, so
  the MCP server and dashboard reading while the timer writes will hit
  "database is locked"; WAL is a precondition for running more than one unit

Constraints already known from linny: the hardened unit sets
`ProtectHome = true`, so state must live outside `/home` and credentials come
from `EnvironmentFile=` (an agenix secret), never a `.env` — startaste resolves
`.env` from the working directory, which the sandbox cannot reach.
