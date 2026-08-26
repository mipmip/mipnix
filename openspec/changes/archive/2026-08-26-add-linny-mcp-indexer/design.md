## Context

Verified on the running host: `linny-mcp serve` opens `stateDir/index.sqlite` but never
populates it (it stayed 64 KB / empty through restarts). The package ships a separate
`lindexer` with subcommands `build` (full rebuild → SQLite/FTS5 in `-state-dir`, plus a
JSON index in `-index`) and `watch` (fsnotify, debounced rebuilds; `-state-dir`
required, `-index` optional). A manual `lindexer build` indexed 2092/2103 notes and the
documents appeared. `serve` re-indexes only on its own writes, so externally-synced
edits (git-sync pulls from the laptops) do not get reflected without a separate indexer.

## Goals / Non-Goals

**Goals:**
- A populated index exists before `serve` starts (first boot, every restart).
- The index tracks all corpus changes: git-sync pulls (remote edits) and agent writes.
- Generated index artifacts never enter the corpus git repo.

**Non-Goals:**
- Changing `linny-mcp serve` or upstream indexer behaviour.
- Committing/persisting the index anywhere but the disposable `stateDir`.
- Solving Hugo-compat / front-matter warnings (harmless; content still indexed).

## Decisions

### Decision: `lindexer watch` long-running service, with `build` as ExecStartPre
Run one `linny-mcp-index` service: `ExecStartPre` does a full `lindexer build` (so the
index is guaranteed populated before `serve`), then `ExecStart` runs `lindexer watch`
for event-driven, debounced rebuilds.
_Alternative rejected:_ a `systemd.timer` running `lindexer build` on a schedule — it
either lags (long interval) or wastes CPU rebuilding the whole corpus repeatedly
(short interval). `watch` is fsnotify-driven and debounced, so it reflects changes
promptly with no polling.

### Decision: order before `linny-mcp.service`, after `secondbrain-clone`
`before = [ "linny-mcp.service" ]` + the ExecStartPre build means `serve` never opens
an empty index. `requires`/`after` `secondbrain-clone.service` guarantees the corpus
exists first.

### Decision: JSON index into `stateDir`, not the corpus
`lindexer build` emits a JSON index (default `./lindenIndex`, relative — which failed
with a permission error). Point `-index` at `${stateDir}/lindenIndex` so the generated
index lives in the disposable state dir and git-sync never tracks or pushes it.

### Decision: run as the `linny-mcp` user
Same owner as the corpus/state and the git-sync unit, so all three share the working
tree cleanly. Not the hardened `serve` sandbox — a plain unit that needs rw to corpus
+ state.

## Risks / Trade-offs

- [Two writers to `index.sqlite`: `serve` rebuilds on its own writes and `watch`
  rebuilds on file changes] → SQLite locking (WAL) should serialize them; rebuilds are
  quick at ~2k notes. If "database is locked" appears, make `watch` the sole indexer
  (accept that serve's own-write rebuild is redundant) — deferred until observed.
- [`watch` could miss an event or die] → `ExecStartPre` build re-establishes a correct
  index on every (re)start, and `Restart = on-failure` recovers crashes.
- [Full rebuilds on every change] → acceptable at this corpus size per upstream
  (~5k notes); incremental/watch tuning is upstream's concern.

## Migration Plan

1. Add the service to `linny-mcp.nix`.
2. `nix eval` the unit renders (ExecStart uses `lindexer watch`).
3. Deploy dapperehaan over LAN `192.168.2.22`.
4. Verify: service active; `index.sqlite` populated (~MBs); edit a note on GitHub →
   git-sync pulls → index rebuilds → the note is searchable; healthz still ok.

Rollback: remove the service and redeploy; the last-built index remains until stale.

## Open Questions

- If dual-writer lock contention shows up, do we disable `serve`'s own-write rebuild
  (no module option today) or just let `watch` win? (Current: leave both; revisit.)
