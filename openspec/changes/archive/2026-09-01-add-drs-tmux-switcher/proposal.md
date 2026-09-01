## Why

`dirty-repo-scanner` (drs) 0.3.0 adds a `--multiplex` mode: it lists dirty git repos in a
TUI, and pressing Enter runs a configured `switch_command` with the selected repo, then
quits — purpose-built for a tmux popup. Today there is no keybinding to invoke it and no
`switch_command` configured, so the feature is unusable. The goal: `prefix + R` opens a
popup running `drs --multiplex`; selecting a repo drops you into a tmux window for that repo
inside a dedicated `dirtyrepos` session, creating the session/window only if absent.

This mirrors an existing, proven pattern in the same config: the `prefix + H` `nebula-ssh`
launcher already does the create-or-select session+window dance from inside a `-E` popup.

## What Changes

- Add a `drs-switch` wrapper (a `writeShellScriptBin`, like `nebula-ssh`) that takes a repo
  directory, derives the window name from its basename, and does create-or-select into a
  `dirtyrepos` session before `switch-client`.
- Set `switch_command: drs-switch %WORKING_DIRECTORY` in the drs `config.yml`.
- Add `bind R popup -E -w 80% -h 80% 'drs --multiplex'` to the tmux config, and add
  `drs-switch` to `home.packages`.

## Capabilities

### New Capabilities
- `drs-tmux-switcher`: a `prefix + R` tmux popup running `drs --multiplex`, plus the
  `switch_command` wrapper that routes the selected repo into a create-or-select `dirtyrepos`
  session/window.

### Modified Capabilities
- (none)

## Impact

- **Code**:
  - `modules/USERS/pim/programs/tmux/default.nix` — add `drs-switch` wrapper, the `bind R`
    binding, and the package.
  - `modules/USERS/pim/programs/dirty-repo-scanner/config.yml` — add `switch_command`.
- **Dependencies**: `drs` ≥ 0.3.0 (already installed via the flake input), `tmux` (already
  configured).
- **Systems**: tmux + drs for user `pim`.
- **Risk**: Low, additive. Known edge case: two dirty repos sharing a basename collide on the
  same window name (accepted for v1, see design).
