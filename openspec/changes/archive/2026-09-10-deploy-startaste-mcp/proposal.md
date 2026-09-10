## Why

startaste collects Pim's GitHub stars and Hacker News upvotes into a SQLite
database, and upstream v3.1.0 already ships an MCP server over that data plus a
NixOS module to run it. Nothing hosts it yet, so the collection is only reachable
from a laptop shell. Hosting it on dapperehaan behind durer makes "what have I
starred / upvoted about X" answerable from Claude Online and Claude Mobile, the
same way `secondbrain.pimsnel.com` already exposes the linny corpus.

## What Changes

- Add a `startaste` flake input (upstream `nixosModules.startaste` and
  `overlays.default`), so the service is consumed rather than repackaged.
- Run the upstream module on dapperehaan with three units enabled:
  - **periodic sync** — the module's oneshot + timer, default `1h` interval
  - **MCP server** — bound to dapperehaan's nebula IP `192.168.100.2:8766`
  - **dashboard** — bound to `192.168.100.2:8421`, mesh-only, never public
- Front the MCP server from durer with an SSE-safe HTTPS vhost at
  `https://taste.pimsnel.com/mcp`, mirroring the existing `secondbrain.pimsnel.com`
  vhost.
- Add two agenix secrets, both encrypted for `[ pim dapperehaan ]`:
  - `startaste-env` — source credentials (`GITHUB_TOKEN`, `HN_COMMENTS_ACCT`,
    `HN_COMMENTS_PW`) consumed as the module's `environmentFile`
  - `startaste-mcp-tokens` — the JSON file of hashed bearer-token records
- No changes to the startaste application itself, and no changes to the existing
  linny-mcp deployment. Not a breaking change.

## Capabilities

### New Capabilities

- `startaste-hosting`: how startaste is hosted across dapperehaan and durer — the
  units that run, what they bind, where state and credentials live, and the public
  TLS endpoint that fronts the MCP server. Follows how `linny-mcp-hosting` keeps
  the service host and the proxy host in one capability.

### Modified Capabilities

None. `durer-nginx-acme` covers nginx and ACME being enabled on durer, which this
change relies on but does not alter — the new vhost belongs to
`startaste-hosting`, matching how the `secondbrain.pimsnel.com` vhost lives in
`linny-mcp-hosting`.

## Impact

- `flake.nix` — one new input (`startaste`, with `inputs.nixpkgs.follows`).
- `modules/HOSTS/dapperehaan-server/startaste.nix` — new.
- `modules/HOSTS/durer-server/taste.nix` — new.
- `secrets/secrets.nix` — two new entries; two new `.age` files under `secrets/`.
- New state on dapperehaan under `/var/lib/startaste` (the module creates it).
- Ports occupied on dapperehaan's mesh IP: `8766` (MCP) and `8421` (dashboard).
  `8765` stays with linny-mcp; there is no collision.
- `taste.pimsnel.com` DNS already resolves to durer, so no DNS work remains.
- Prerequisite outside the repo: bearer tokens must be minted with
  `startaste mcp-token` before the secret can be written.
