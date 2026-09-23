## Context

drs `--multiplex` is documented in `--help` as: "multiplex mode: Enter runs switch_command
and quits (for tmux popups)". So drs needs a `switch_command` in its `config.yml`, and tmux
needs a binding to launch the popup. The whole feature is a re-skin of the existing
`nebula-ssh` launcher (`bind H`), which already performs create-or-select of a session +
window from inside a `-E` popup and retargets the outer client with `switch-client`.

```
  prefix + R → popup(-E) → drs --multiplex → [Enter on repo]
                                              → switch_command = drs-switch <dir>
                                              → create-or-select dirtyrepos:<name>
                                              → switch-client ; drs quits ; popup closes
```

## Decisions

### Decision 1: Put the switch logic in a `drs-switch` wrapper, not inline in config
The create-or-select logic is multi-line (has-session / list-windows / new-* / switch-client).
The config precedent (`nebula-ssh`, `beans-tui-popup`) is to package such logic as a
`pkgs.writeShellScriptBin` added to `home.packages`, then reference it by name.

- **Choice**: `drs-switch` wrapper packaged like `nebula-ssh`.
- **Alternative rejected**: A one-line inline `switch_command` with chained tmux calls —
  unreadable and hard to guard for the create-or-select branches.

### Decision 2: Derive the window name from `basename`, not an undocumented placeholder
The only substitution proven in the existing config is `edit_command: ... %WORKING_DIRECTORY`,
so `switch_command: drs-switch %WORKING_DIRECTORY` is the safe contract. The wrapper computes
`name = basename "$dir"` rather than relying on a possibly-nonexistent `%REPO_NAME`.

- **Choice**: `%WORKING_DIRECTORY` only; window name = basename in the wrapper.
- **Alternative rejected**: Depend on a `%REPO_NAME` placeholder — not confirmed to exist in
  drs 0.3.0.

### Decision 3: Session `dirtyrepos`, exact-match targets, `-c "$dir"` start dir
Mirror `nebula-ssh` precisely: use `-t "=dirtyrepos"` exact-match targeting, create with
`new-session -d` / `new-window -d`, and switch with `switch-client -t "=dirtyrepos:$name"`.
New windows/sessions start in the repo dir via `-c "$dir"` and run the default shell (no
command), unlike nebula which runs `ssh`.

```
  has-session -t =dirtyrepos ?
    no  → new-session -d -s dirtyrepos -n <name> -c <dir>
    yes → window <name> exists ?  no → new-window -d -t =dirtyrepos -n <name> -c <dir>
  switch-client -t =dirtyrepos:<name>
```

### Decision 4: Keybinding `R`, popup 80%×80%
`R` (repos) is free in the current bindings (`s S G T B D H P O b a` are taken). Size matches
the sibling TUI popups `bind G` (hup) and `bind T` (tj).

## Known edge case (accepted for v1)

**Basename collisions.** Two dirty repos with the same basename (e.g. `~/work/config` and
`~/play/config`) map to the same window name; selecting the second reuses the first's window.
Accepted for v1 — repo names are rarely duplicated in practice, and `nebula-ssh` makes the
same assumption for host names. Disambiguation (parent-dir prefix or hash suffix) is a
possible follow-up if it bites.

## Open question (defer)
- Whether drs exposes richer placeholders (`%REPO_NAME`, etc.) — not needed for v1, but if
  confirmed later the wrapper could drop the `basename` step.
