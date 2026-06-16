## Context

The tmux config (`modules/USERS/pim/programs/tmux/default.nix`, gpakosz/.tmux framework)
already launches TUIs via `display-popup`:

```
bind S popup -E smg
bind T popup -E -w 80% -h 80% 'tj --columns --sort-activity --no-sound --no-notify --picker'
bind P display-popup -d '#{pane_current_path}'
```

`beans` is a system package (`/run/current-system/sw/bin/beans`) with a `tui` subcommand
("Open the interactive TUI"). This change adds one more bind following the `T` pattern.

## Goals / Non-Goals

**Goals:**
- One keybinding that opens `beans tui` in a large popup over the current session.

**Non-Goals:**
- Packaging beans (already on PATH), theming the popup, or changing beans itself.
- Any non-tmux launcher (e.g. a Hyprland keybind) — scoped to tmux.

## Decisions

### Bind: `prefix + B`, 90% × 90%, `-E`, pane cwd

```
bind B popup -E -w 90% -h 90% 'beans tui'
```

- **Key `B`** (uppercase): mnemonic for Beans; currently unbound (lowercase `b` is the
  status-bar toggle), so nothing is displaced.
- **90% × 90%**: "large" per the task; slightly bigger than the `T` bind's 80% (a
  task/bean TUI benefits from the extra room). User-chosen.
- **`-E`**: popup closes when `beans tui` exits — matches the `S`/`T` binds.
- **Pane cwd**: no `-d` flag → popup uses the active pane's working directory, so it shows
  the beans for the current project. Matches the default behavior of the `T` bind.

**Alternative considered**: explicit `-d '#{pane_current_path}'` (as the `P` bind uses) to
force the active pane's path. Marginally more robust in edge cases, but the no-`-d` default
already resolves to the active pane's cwd and matches the dominant `T` convention. Going
with the simpler form; can add `-d` later if a cwd edge case appears.

## Risks / Trade-offs

- **[Risk] beans cwd resolution** → if `beans tui` resolves its `.beans` dir relative to
  cwd, the popup shows the current project's beans (intended). If beans ever resolves a
  global dir instead, the popup would show global beans regardless of cwd — acceptable,
  and not changed by this bind.
- **[Trade-off] 90% vs 80%** → inconsistent with the `T` bind's 80%, but intentional per
  the "large" request.

## Migration Plan

1. Add the `bind B ...` line near the other popup binds in `tmux/default.nix`.
2. Rebuild + reload tmux config.
3. Verify: `prefix + B` opens a ~90% popup running `beans tui` in the pane's cwd; quitting
   the TUI closes the popup; no other binding broke.

**Rollback**: remove the bind line; rebuild.

## Open Questions

- None.
