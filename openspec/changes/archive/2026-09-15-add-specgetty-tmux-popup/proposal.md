## Why

specgetty browses the OpenSpec projects on this machine, which is most of what
this repo's workflow produces, and it is the only such tool with no tmux
binding. Opening it means leaving the pane you are in, starting it by hand, and
finding the project you were already standing in.

The input is also stale in two ways. It names `github:mipmip/specgetty`, an
owner that no longer owns the repository (it moved to the `speclib`
organisation, and only GitHub's redirect keeps the URL working), and it is
pinned to v0.2.0 from 2 April 2026 while upstream is at v0.3.0.

The two are one piece of work because v0.3.0 removed the flag the binding would
otherwise need. In v0.2.0 the current project is `spg --zoom`; in v0.3.0 that
flag is gone, `--view single` is the default, and plain `spg` does it. A binding
written against the installed version would have to be rewritten by the update,
so they land together.

## What Changes

- The `specgetty` flake input points at `github:speclib/specgetty` and is
  updated to v0.3.0, naming the current owner instead of relying on a redirect.
- A registry entry binds `prefix + A` to a popup running `spg` at the pane's
  current path, listed in the `prefix + ?` menu like every other tool.
- The popup needs no launcher script. v0.3.0 walks up from the working directory
  for an `openspec/` directory itself, and offers its project picker when there
  is none, so the flash-close problem that `beans-tui-popup` exists to solve
  does not arise here.
- The existing `~/.config/specgetty/config.yml` is unchanged. v0.3.0 adds two
  optional keys (`edit_command`, `change_fields`) and the current file stays
  valid without them.

## Capabilities

### New Capabilities

- `specgetty-tmux-popup`: specgetty installed from the `speclib` input at a
  version whose default view resolves the project from the working directory,
  and the `prefix + A` popup that opens it there.

### Modified Capabilities

None. The binding is an ordinary entry in the existing `tmux-bind-registry`,
which needs no change to carry it.

## Impact

- `flake.nix` and `flake.lock`: the `specgetty` input URL and its locked
  revision.
- `modules/USERS/pim/programs/tmux/default.nix`: one entry in `customBinds`,
  which emits both the `bind A` line and the menu entry.
- `prefix + A` was unbound, so no existing key changes behaviour.
- The menu grows from 13 entries to 14, which raises the client height it needs
  from 16 rows to 17. Both are well inside any normal terminal.
- Out of scope, though the file is touched by neither concern:
  `modules/USERS/pim/programs/specgetty/default.nix` declares itself into
  `flake.modules.homeManager.pim-git` and writes its config through
  `home.file."./.config/..."` rather than `xdg.configFile`. Both are worth
  normalising, neither is part of this change.
