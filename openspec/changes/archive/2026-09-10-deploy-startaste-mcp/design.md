## Context

See proposal.md — Why.

The decisive fact shaping this design: **upstream already does almost all of it.**
startaste v3.1.0 ships `nix/module.nix` exposing `services.startaste` with
`sync.enable`/`sync.interval` (default `1h`), `mcp.enable`/`listenAddress`/`port`
(default `8766`)/`tokensFile`, `dashboard.*`, `environmentFile`, a hardened unit
profile, `/var/lib/startaste` state with tmpfiles pre-creation, and assertions
covering "tokensFile required when mcp is on" and "mcp.port ≠ dashboard.port". It
exposes `nixosModules.startaste` and `overlays.default`, and carries its own
`openspec/specs/mcp-server/spec.md` and `specs/nixos-service/spec.md` describing
the contract.

So this is a wiring change, not a build change. The instruction was "just like
linny", and that overshoots — the shapes differ substantially:

```
  linny-mcp.nix on dapperehaan (existing)      startaste.nix (this change)
  ─────────────────────────────────────────    ────────────────────────────────
  import module + overlay                      import module + overlay
  2 agenix secrets                              2 agenix secrets
  services.linny-mcp { … }                      services.startaste { … }
  tmpfiles (3 dirs)                             ─ module does it
  secondbrain-clone.service   (bootstrap)       ─ no git corpus
  git-sync-secondbrain.service + .timer         ─ syncs itself
  linny-mcp-index.service (build + watch)       ─ no external indexer
```

linny needs four extra units because its corpus is a git repository that the
server does not index. startaste owns a SQLite database and refreshes it itself,
so all of that disappears.

Target topology:

```
                        Internet
                           │  https://taste.pimsnel.com/mcp
                           ▼
                ┌──────────────────────────┐
                │  durer  (public)         │  nginx + ACME already enabled
                │  :80 :443                │  NEW vhost: taste.pimsnel.com
                └────────────┬─────────────┘
                             │ nebula overlay
                             │ http://192.168.100.2:8766
                             ▼
      ┌────────────────────────────────────────────────────┐
      │  dapperehaan   192.168.100.2                       │
      │   startaste-mcp.service       :8766   ◀── new      │
      │   startaste-dashboard.service :8421   ◀── new, mesh-only
      │   startaste-sync.timer        1h      ◀── new      │
      │   /var/lib/startaste/startaste.db                  │
      │   linny-mcp.service           :8765   ← existing   │
      └────────────────────────────────────────────────────┘
```

Two environment facts were verified rather than assumed:

- **Mesh reachability needs no firewall work.** `modules/services/networking/nebula.nix`
  sets `firewall.inbound` to `any/any/any`, and `dapperehaan-server/networking.nix`
  sets `networking.firewall.enable = false`. Ports 8766 and 8421 are reachable over
  the overlay with no extra configuration.
- **DNS has already landed.** `taste.pimsnel.com` resolves to `178.104.252.76`, the
  same address as `secondbrain.pimsnel.com`, i.e. durer. No DNS work remains and
  ACME HTTP-01 will succeed on first deploy.

## Goals / Non-Goals

**Goals:**

- Carry host wiring only; no packaging or unit definitions duplicated from upstream.
- Keep every credential out of `/nix/store`.
- Keep the MCP server off every public interface; TLS terminates on durer.
- Leave the existing linny-mcp deployment untouched.

**Non-Goals:**

- Any change to the startaste application, its flake, or its module. If an option
  is missing, it gets added upstream, not worked around here.
- A public endpoint for the dashboard.
- Ordering units that make the MCP server wait for a first sync (see Decisions).
- Monitoring or alerting on sync failures. `ntfy` for linny is already deferred to
  `.beans/mipnix-2dyz`; this deployment does not get ahead of it.

## Decisions

### Accept the cold-start gap rather than order around it

The MCP server opens the database read-only and refuses to create one, so on a
freshly deployed host it cannot serve until the first sync has run. Upstream
handles this deliberately: `Restart = always`, `RestartSec = 30`, and
`StartLimitIntervalSec = 0` so it retries forever instead of exhausting a start
limit and staying dead.

The sequence on first deploy:

```
boot ──▶ startaste-mcp starts ──▶ no database ──▶ exits ──┐
                                                           │ retry / 30s
  +2min ──▶ startaste-sync runs (first sync takes minutes) │
                                                           ▼
                                          database exists ──▶ mcp serves
```

`https://taste.pimsnel.com/mcp` therefore 502s for the first several minutes after
the initial deploy. Accepted as-is.

*Alternative considered:* a oneshot initial sync that the MCP unit requires and is
ordered after. Rejected — it buys a tidier first five minutes and introduces a new
failure mode (a slow or failing first sync now blocks the server permanently
instead of delaying it), and it fights a choice upstream made on purpose.

### Credentials via `environmentFile`, never a `.env`

The module's own comment is explicit: "The application's own `.env` discovery is
unusable here: the unit sets `ProtectHome = true`, and `.env` is resolved from the
working directory." A `.env` placed anywhere on dapperehaan would never be read.

So credentials go in `secrets/startaste-env.age`, decrypted to
`/run/agenix/startaste-env`, owned by the `startaste` user, referenced by path.

One trap worth writing down: systemd's `EnvironmentFile` is **not** a dotenv
parser. `export FOO=bar` breaks, `FOO=$OTHER` is literal, an inline `# comment`
after a value can be swallowed, and exactly one surrounding quote pair is stripped.
An existing `.env` needs a pass before being encrypted, and values containing `#`,
`$` or spaces should be single-quoted.

### Both sources enabled, accepting the HN credential's blast radius

The GitHub side is a scopeless (or Starring-read-only) token — negligible reach.
Hacker News has no API: startaste scrapes with `HN_COMMENTS_ACCT` and
`HN_COMMENTS_PW`, i.e. the real account password, which now lives encrypted on
dapperehaan and decrypted at `/run/agenix` while the unit runs.

This was raised and accepted: the whole `.env` goes in, both sources sync. Recorded
here as a known exposure rather than a live question. The module syncs only
configured sources, so dropping HN later is a one-line change to the secret.

### Dashboard on the mesh, deliberately unauthenticated

`dashboard.enable` defaults to off and its own option description says it has "NO
authentication of any kind". Binding it to `192.168.100.2:8421` makes it browsable
from any nebula node and from nowhere else. No durer vhost points at it.

The trade is explicit: any host on the overlay can read the whole collection
without credentials. Accepted, because the overlay is a trusted network and the
data is a list of things Pim has publicly starred and upvoted.

### One bearer token per client

`startaste mcp-token --name <client>` mints a 256-bit `token_urlsafe` value and
prints a `{"name", "hash", "scopes"}` record holding its hex SHA-256. The tokens
file is a JSON list of those records.

Minting one record per client (Claude Online, Claude Mobile, CLI) makes revocation
per-client: delete the record, redeploy. A single shared token would mean revoking
one client revokes all of them.

The format is identical to linny's — `startaste/mcp/auth.py` states it mirrors
`linny-mcp-server/internal/auth` so both services on this host behave the same way
— so the existing `linny-mcp-tokens.age` is a working template.

### Vhost copied from `secondbrain.nix`, not invented

durer's `secondbrain.nix` already solves SSE-safe MCP proxying: `proxyWebsockets`
for HTTP/1.1, `proxy_buffering off`, `proxy_request_buffering off`, 3600s read and
send timeouts, `chunked_transfer_encoding off`. The new vhost differs only in
hostname and upstream port. Diverging from a proven vhost would be gratuitous.

## Risks / Trade-offs

- **A malformed token record fails silently.** `auth.py` skips a malformed record
  with a warning rather than rejecting the file, so a typo disables one client
  while the others keep working → when a client gets 401s, suspect its record
  before the server.
- **A missing token file is indistinguishable from cold start in the journal.**
  Both make `startaste-mcp` exit and retry. → When the unit is flapping after a
  deploy, check the token secret's presence and ownership before assuming it is
  waiting for the first sync.
- **agenix ownership depends on the service user existing at activation.** The
  module creates the `startaste` system user only while `user` is left at its
  default → keep it at the default. linny-mcp relies on the same mechanism on this
  same host, so the pattern is already proven here.
- **The HN scraper is credential-based and unversioned.** An HN login or markup
  change breaks sync with an auth failure → upstream reports source auth failures
  cleanly and keeps syncing the rest, and a failing run does not stop the timer, so
  the GitHub half keeps working.
- **Two MCP services now share dapperehaan.** Ports are distinct (8765 / 8766 /
  8421) and the units are independent → no interaction beyond host resources.
- **Upstream is young** (v3.1.0, MCP added very recently) → the input is pinned by
  `flake.lock`, so an upstream change lands only on a deliberate `nix flake update`.

## Open Questions

- Sync interval: the module's `1h` default is taken as-is. GitHub stars and HN
  upvotes change slowly, so `6h` would likely be plenty. Deferrable — it is one
  option value and changes no spec, no approach and no task.
