## Context

Current wrapper (`hup-tmux-switch`) is called positionally as
`hup-tmux-switch <short> <owner> <repo> <target>` and builds `sess="$short->$owner"` itself, so
the collection can't influence the session. huphop renders `switch_command` as a Go template then
splits it into argv with shell-word rules (no shell), running it while the TUI still owns the
terminal — only tmux server commands, no TTY. hup 1.4 adds `{{.Collection}}` (empty outside a
collection; the name may contain spaces, kept as one argv entry by hup's pre-split substitution).

## Decisions

### Decision 1: Bump the huphop input to 1.4 (hard prerequisite)
`{{.Collection}}` — and even `{{if .Collection}}` — fails at execute time on 1.3 ("can't evaluate
field Collection in type tui.switchData"), which aborts the switch. So the template change cannot
land without the input bump.

- **Choice**: bump `inputs.huphop` to a rev/tag that includes `collection-in-switch-command`.
- **Risk**: unrelated 1.4 changes ride along; verify `hup config check` and a normal switch after.

### Decision 2: Extend the existing wrapper, do NOT build the unified tmux-helper
Per scope ("option B only"), reuse `hup-tmux-switch`. The only interface change: accept the
resolved session name as `$1` (was `<short> <owner>`), keeping `<repo> <target>`. The unified
`tmux-helper` (named flags, window-id targeting, absorbing drs/nebula) and the `layout-template`
feature are deferred to a separate change.

- **Choice**: minimal signature change: `hup-tmux-switch <session> <repo> <target>`.
- **Alternative deferred**: the general `tmux-helper` refactor (previously "option A").

### Decision 3: Backward-compatible session naming via template conditional
`{{if .Collection}}{{.Collection}}{{else}}{{.Short}}->{{.OwnerLower}}{{end}}`. Outside a
collection the field is empty, so the session name is exactly today's `short->owner` (after the
wrapper's `tr ':.'` sanitize, which leaves `gh->mipmip` unchanged). Existing sessions are
unaffected; collection sessions are new.

### Decision 4: Keep `tr ':.'` sanitization on the session name
Collection names are free text — a name with a `:` or `.` would corrupt the `=sess:win` switch
target. The existing sanitize (`tr ':.' '--'`) already guards this, so it stays. Spaces are left
intact and are safe inside quoted tmux targets. (The prettier window-id approach used by
`drs-switch` is deliberately NOT adopted here — it belongs with the deferred tmux-helper refactor;
keeping this change minimal.)

## Out of scope
- Unified `tmux-helper`, window-id targeting, porting `drs-switch`/`nebula-ssh`.
- `layout-template` / `3-pane-coding` (needs the helper and a concrete layout definition).
