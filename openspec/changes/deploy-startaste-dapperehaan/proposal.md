<!-- Epic: .beans/mipnix-o4bl--deploy-startaste-on-dapperehaan.md -->

## Why

startaste (`github.com/mipmip/startaste`) syncs Hacker News upvotes and GitHub
stars into a local SQLite database, but only runs by hand on a workstation. We
want it in production on dapperehaan so syncing happens on a schedule and the
collected data becomes reachable: as an MCP endpoint for Claude Online and
Claude Mobile, and as a dashboard over the mesh.

The `linny-mcp-hosting` topology already solves the hard parts of this on the
same two hosts — hardened service on dapperehaan bound to the nebula mesh, TLS
terminating on durer, bearer tokens from agenix, SSE-safe reverse proxy. This
change reuses that shape rather than inventing a second one.

Deliberate decision on "daemon mode": no interval loop goes into the
application. `startaste sync` is already a clean oneshot, so a `Type=oneshot`
unit plus a `systemd.timer` supplies the schedule, restart-with-backoff,
journald logging, and refusal to start an overlapping run.

## What Changes

- Add `startaste` as a flake input; apply its `overlays.default` and import its
  `nixosModules.startaste` on dapperehaan.
- Run **scheduled sync** on dapperehaan: a `Type=oneshot` unit invoking
  `startaste sync`, driven by a `systemd.timer` (hourly; HN upvotes and GitHub
  stars change slowly). Database and state under **`/var/lib/startaste`**
  (outside `/home`, because the unit sets `ProtectHome = true`).
- Run the **MCP server** on dapperehaan bound to the mesh IP
  `192.168.100.2:8766`, with an unauthenticated `/healthz` and bearer-token auth
  on `/mcp`.
- Run the **dashboard** on dapperehaan bound to `192.168.100.2:8421`,
  **mesh-only — no durer vhost**. It has no authentication of any kind, so
  nebula is the access control.
- Add a **durer** nginx vhost `taste.pimsnel.com` (ACME + forceSSL) reverse
  proxying over nebula to `192.168.100.2:8766`, with the SSE-safe settings the
  MCP streamable transport needs — the same set as
  `modules/HOSTS/durer-server/secondbrain.nix`.
- Add two agenix secrets, both encrypted for `[ pim dapperehaan ]`:
  `startaste-mcp-tokens` (hashed bearer-token records) and `startaste-env`
  (an `EnvironmentFile` holding `HN_COMMENTS_ACCT`, `HN_COMMENTS_PW`,
  `GITHUB_TOKEN`). Credentials cannot come from a `.env`: startaste resolves it
  from the working directory, which `ProtectHome` puts out of reach.

Manual, out-of-repo steps (documented in tasks): create the `taste.pimsnel.com`
DNS A-record pointing at durer; mint the bearer token(s); mint a scopeless
GitHub token; put the HN credentials and the GitHub token into the encrypted
env file; configure the Claude Online/Mobile MCP client with the bearer token.

**Depends on upstream startaste work** — this change cannot be applied until:

- `startaste-zrap`: the flake exposes only `packages` and `devShells` today. It
  needs `nixosModules.startaste` and `overlays.default` before any host can
  import it. Blocks everything here.
- `startaste-hq9c`: SQLite is in `journal_mode = delete` with no pragmas set. A
  reader (MCP, dashboard) during the timer's write transaction will hit
  "database is locked". WAL is a precondition for running more than one unit.
- `startaste-qbtu`: the MCP server itself does not exist yet. Tasks for sync and
  the dashboard can land before it; the MCP service and the durer vhost cannot.

## Capabilities

### New Capabilities
- `startaste-hosting`: Production hosting of startaste — flake/overlay/module
  integration, scheduled sync via a timer, the MCP service on dapperehaan behind
  durer's TLS-terminating reverse proxy at `taste.pimsnel.com`, the mesh-only
  dashboard, state location under `/var/lib`, and credential handling through
  agenix.

### Modified Capabilities
<!-- None. The new taste.pimsnel.com vhost is additive; existing durer-nginx-*
     specs are unchanged, as with the secondbrain vhost. -->

## Impact

- `flake.nix` — new `startaste` input (follows nixpkgs).
- `modules/HOSTS/dapperehaan-server/` — new module wiring the three units
  (sync oneshot + timer, MCP, dashboard), the `/var/lib/startaste` state dir,
  and the two agenix secrets.
- `modules/HOSTS/durer-server/` — new `taste.pimsnel.com` vhost, modelled on
  `secondbrain.nix`.
- `secrets/secrets.nix` — `startaste-mcp-tokens.age` and `startaste-env.age`,
  recipients `[ pim dapperehaan ]`.
- External: DNS record, GitHub token, HN credentials, bearer token, and the MCP
  client config (manual).
- Depends on the nebula mesh (durer↔dapperehaan) already in place, and on the
  three upstream startaste items listed above.
- Port allocation on dapperehaan's mesh IP: linny-mcp already holds 8765;
  startaste takes 8766 (MCP) and 8421 (dashboard, its upstream default).
