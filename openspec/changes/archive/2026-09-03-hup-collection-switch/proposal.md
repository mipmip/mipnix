## Why

huphop 1.4 adds repo *collections* (curated, named groups of repos) and exposes the active
collection to the multiplex `switch_command` as `{{.Collection}}`. That unlocks the natural
tmux workspace layout — one session per collection, one window per repo — instead of the
current fixed "one session per `short->owner`". Today's config (`modules/USERS/pim/programs/
huphop/default.nix`) pins hup 1.3.0, whose template context has no `Collection` field, and its
`hup-tmux-switch` wrapper hardcodes the session name from `short`/`owner`. This change makes the
session name collection-aware while preserving current behavior outside a collection.

## What Changes

- Bump the `huphop` flake input to a 1.4 revision that includes `Collection` in the
  `switch_command` template context (the upstream `collection-in-switch-command` change).
- Change `hup-tmux-switch` to take the resolved session name as its first argument (instead of
  computing `short->owner` internally); it keeps `repo` and `target`, and keeps sanitizing the
  session/window names out of tmux's `session:window.pane` target grammar.
- Set the multiplex `switch_command` session name to
  `{{if .Collection}}{{.Collection}}{{else}}{{.Short}}->{{.OwnerLower}}{{end}}` — a collection
  session when inside a collection, the current `short->owner` session otherwise.

Explicitly **out of scope** (deferred): the unified `tmux-helper` refactor, window-id targeting,
porting `drs-switch`/`nebula-ssh`, and the `layout-template` feature. This change is only the
hup config + input bump.

## Capabilities

### Modified Capabilities
- `huphop-tmux-switcher`: the multiplex `switch_command` session name becomes collection-aware
  (session per collection when in one, `short->owner` otherwise); requires huphop ≥ 1.4.

## Impact

- **Code**:
  - `flake.nix` / `flake.lock` — bump the `huphop` input to ≥ 1.4.
  - `modules/USERS/pim/programs/huphop/default.nix` — wrapper arg change + `switch_command` template.
- **Dependencies**: huphop ≥ 1.4 (provides `{{.Collection}}`).
- **Systems**: hup multiplex switcher (`prefix + G`) for user `pim`.
- **Risks**: The input bump 1.3→1.4 could carry unrelated upstream changes (mitigation: 1.4's
  collection work is documented as additive; verify `hup config check` post-bump). If the input is
  NOT bumped, the `{{if .Collection}}` template errors at switch time — so the bump is a hard
  prerequisite, not optional.
