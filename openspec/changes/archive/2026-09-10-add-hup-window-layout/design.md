## Context

See proposal.md — Why.

The only seam is `hup-tmux-switch`, the `writeShellScriptBin` wrapper in
`modules/USERS/pim/programs/huphop/default.nix`. huphop renders
`switch_command` as a template and execs it **without a shell**, so all
branching lives in that one script. It runs while the TUI still owns the
terminal and has no controlling TTY, so it may only issue tmux server commands.

Its current shape has exactly three paths, two of which create a window:

```
                        ┌─ session missing ──▶ new-session -d -s $sess -n $win -c $target   ← creates
hup selects repo ──────▶├─ window missing ───▶ new-window  -d -t $sess -n $win -c $target   ← creates
                        └─ both exist ───────▶ (nothing)
                                                        │
                                                        ▼
                                              switch-client -t $sess:$win
```

Two constraints come from `modules/USERS/pim/programs/tmux/default.nix`:

- `pane-base-index 1` (line 132) — pane indices start at 1, so `.0`/`.1`
  reasoning is wrong here.
- `main-pane-width 80` is set globally (absolute columns, not a percentage), and
  every smug project in `smug_n_skull/_advanced_smugs.nix` uses
  `layout = "main-vertical"` on top of it.

## Goals / Non-Goals

**Goals:**

- Get the layout in without touching session/window naming, the huphop config,
  or the `prefix + G` binding.
- Keep the wrapper TTY-free and shell-free-safe.
- Be immune to the `pane-base-index` setting rather than encoding it.

**Non-Goals:**

- A reusable layout helper shared with smug or `nebula-ssh`. If a second caller
  appears, extract then.
- Making the layout configurable (pane count, ratios, per-repo overrides).
- A tmux `after-new-window` hook. That would catch every window in every
  session, not just hup's.

## Decisions

### Two explicit `split-window` calls, not `select-layout main-vertical`

The requested shape *is* tmux's `main-vertical` with three panes, and the repo
already leans on named layouts via smug. Rejected anyway: `main-pane-width` is
globally `80` — absolute columns — so a bare `main-vertical` yields an
80-column left pane rather than half the window. Getting 50% would need either a
per-window `setw main-pane-width 50%` (extra state on the window) or changing the
global that smug's layouts depend on.

Two `split-window -l 50%` calls avoid the entanglement and read as exactly what
the spec describes.

*Alternative considered:* a raw `select-layout '<layout-string>'`. Rejected —
layout strings encode absolute cell geometry, so they are wrong at any window
size other than the one they were captured at.

### Address panes by pane id, never by index

Capture ids from the creating command and each split with
`-P -F '#{pane_id}'`, then target `%N` throughout.

`pane-base-index 1` makes index arithmetic a trap, and the wrapper runs detached
where "the currently active pane" is not a safe referent. The tmux module already
uses this technique for window ids (`tmux/default.nix:94`), so it matches house
style.

*Alternative considered:* target `$sess:$win.1` etc. Rejected — correct only as
long as `pane-base-index` stays 1.

### Layout on creation only; never repair

The wrapper applies the layout inside the two branches that create a window, and
does nothing on the already-open path.

Rationale: the existing spec's "Repo already open → the wrapper creates nothing"
scenario is a promise that re-selecting a repo is inert. A window that silently
re-splits itself after you deliberately closed a pane is the kind of behaviour
that gets switched off.

*Alternative considered:* an "ensure layout" pass on every selection, so a window
always has three panes. Rejected for the reason above, and it would need a
rule for what to do with panes running foreground processes.

### Splits inherit `-c "$target"` explicitly

Each `split-window` passes `-c "$target"` rather than relying on inheritance
from the pane being split, so all three panes are rooted at the checkout
regardless of the split source.

### Focus set explicitly after the splits

Each split uses `-d` so the new pane does not steal focus, and the wrapper then
calls `select-pane` on the captured left-pane id before `switch-client`. Relying
on `-d` alone would leave focus wherever tmux last put it.

## Validated by spike

Run against a scratch server (`tmux -L …`, tmux 3.6a) with `pane-base-index 1`
and `main-pane-width 80` mirrored, so these are measurements and not assumptions:

| Check                                          | Result                                    |
|------------------------------------------------|-------------------------------------------|
| `new-session -d -P -F '#{pane_id}'`            | returns a pane id; same for `new-window`  |
| `split-window -h -l 50%` then `-v -l 50%`      | 39/40 columns, then 24/25 rows            |
| `select-pane` on the captured first id         | left pane reports `active=1`              |
| `-c <target>` on all three                     | `pane_start_path` correct on all three    |
| resize 200x50 → 120x40                         | proportions held (59/60 columns)          |
| both creation branches                         | identical result                          |

One earlier worry was measured away: a window too small to split. Forced down to
12x4, tmux still performed both splits without error, so no guard is needed.

## Risks / Trade-offs

- **`pane_current_path` reads stale immediately after a split** → Only a
  measurement artifact: the pane's shell has not started yet, so tmux reports the
  server's cwd. `pane_start_path` is correct straight away, and `pane_current_path`
  settles once the shell is up. Any verification must query after the shells
  start, not in the same breath as the splits.
- **Three panes is wrong for narrow monitors** → Accepted. Not configurable by
  choice (see Non-Goals); the user can close panes, and per the layout-on-creation-
  only decision the wrapper will not put them back.
- **Two extra tmux round-trips per newly created window** → Negligible; these are
  local server commands on a socket, and they run once per window, not per switch.
- **Drift if a future tmux changes `-l <percent>` semantics** → Low. `-l` with a
  percentage is the current documented form; the deprecated `-p 50` is the
  fallback if it ever regresses.
