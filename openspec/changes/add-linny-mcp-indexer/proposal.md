## Why

`linny-mcp serve` only *reads* an index; it never builds one. In the production
deployment the index was empty, so MCP clients saw zero documents until the index
was built by hand with `lindexer`. Worse, even once built it goes stale: `serve`
re-indexes only on its *own* writes, so notes edited elsewhere and pulled in by
git-sync never become searchable. The deployment needs `lindexer` running so the
corpus index is populated before `serve` starts and stays current as the corpus
changes.

## What Changes

- Add a `linny-mcp-index` systemd service on dapperehaan that runs the `lindexer`
  binary (from the same `linny-mcp` package):
  - `ExecStartPre`: `lindexer build` — a full rebuild so `serve` always has a
    populated index (including the first boot and every restart).
  - `ExecStart`: `lindexer watch` — fsnotify, debounced rebuilds whenever the
    corpus changes (git-sync pulls of remote edits **and** agent writes).
- Order it **after** the corpus clone and **before** `linny-mcp.service`, run as the
  `linny-mcp` user, with the generated JSON index written to the disposable
  `stateDir` (never into the git-tracked corpus).

## Capabilities

### Modified Capabilities
- `linny-mcp-hosting`: adds a requirement that the corpus index is built before the
  server serves and kept current as the corpus changes (via `lindexer` build+watch),
  and that generated index artifacts stay out of the corpus git repo.

## Impact

- `modules/HOSTS/dapperehaan-server/linny-mcp.nix` — new `systemd.services.linny-mcp-index`
  (build+watch), ordered before `linny-mcp.service`.
- No new inputs/secrets. `lindexer` ships in the already-imported `linny-mcp` package.
- Follow-up to the archived `deploy-linny-mcp-secondbrain` change (same host/module).
