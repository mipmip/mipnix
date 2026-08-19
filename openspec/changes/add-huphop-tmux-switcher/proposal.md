## Why

I already have a `prefix + S` tmux popup (`smg`) that lists my smug sessions and
switches to the chosen one. huphop (`hup`) can do the equivalent for my whole git
portfolio — list every repo across my GitHub orgs, clone on demand, and hand off a
`switch_command` — but there is no tmux entry point for it, and its config lives as
a hand-edited `~/.config/huphop/config.yaml` outside home-manager. This makes the
switcher unusable from tmux and the config non-reproducible.

## What Changes

- Add a tmux binding `prefix + G` that opens a popup running
  `hup tui --mode multiplex --flatlist` (mirrors the existing `prefix + S` smug popup).
- Generate `~/.config/huphop/config.yaml` from Nix (`xdg.configFile`), replacing the
  current hand-written file. Content reproduces the current working config verbatim,
  except the multiplex `switch_command`.
- Add a `hup-tmux-switch` wrapper (`pkgs.writeShellScriptBin`) implementing the
  **session-per-org / window-per-repo** model: create the org session and/or repo
  window if missing, otherwise just switch. The wrapper is referenced by Nix store
  path in `switch_command`, so the config is hermetic (no PATH dependency).

## Capabilities

### New Capabilities
- `huphop-tmux-switcher`: home-manager-managed huphop configuration plus a tmux
  popup binding and switch wrapper that opens the huphop multiplex TUI and
  creates-or-switches a tmux session (per org) and window (per repo) for the
  selected repository, cloning it first if needed.

### Modified Capabilities
<!-- None. This introduces new behavior; no existing spec's requirements change. -->

## Impact

- `modules/USERS/pim/programs/huphop/default.nix` — currently only adds the huphop
  package; gains the Nix-generated config and the `hup-tmux-switch` wrapper.
- `modules/USERS/pim/programs/tmux/default.nix` — gains the `bind G popup -E` entry.
- Replaces the hand-written `~/.config/huphop/config.yaml` on next home-manager
  switch (home-manager takes ownership of the file).
- Depends on the `huphop` flake input and the `hup` binary already on PATH via the
  huphop home package; `tmux` and `gh` (auth) at runtime.
- Out of scope: changing huphop itself, auth/token setup, adding new providers.
