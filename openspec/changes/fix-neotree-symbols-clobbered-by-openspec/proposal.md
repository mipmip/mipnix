## Why

Modified files in the neo-tree file tree show a box/tofu glyph instead of a git marker
(e.g. `tsconfig.tsbuildinfo` with git status `' M'`). Root cause, verified at source and
via a live nvim socket: the custom `git_status.symbols` configured in mipvim's neo-tree
setup are silently discarded, and neo-tree falls back to its built-in defaults — whose
default `unstaged` symbol is `U+F0131`, a glyph that does not render in the active font.

The discard happens because neo-tree's `setup()` is called twice. mipvim's
`neo-tree.setup({ default_component_configs = { git_status = { symbols = ... } } })` runs
first (correct), but the `openspec.nvim` plugin's `setup({ neotree = true })` later calls
`require("neo-tree").setup({ filesystem = { components = {...} } })` **without**
`default_component_configs`. neo-tree's second `setup()` resets component configs to
defaults plus only what that call passes, so the custom symbols revert to defaults. Live
nvim confirms all git_status symbols are neo-tree defaults (`unstaged=U+F0131`,
`modified=U+F444`, `added=U+271A`, ...), none of the configured values.

This is a load-order / setup-clobbering bug, not a font problem — the configured glyph
`U+F06A9` renders correctly; the default `U+F0131` does not.

## What Changes

- Make mipvim's neo-tree `default_component_configs` (including `git_status.symbols`)
  survive the `openspec.nvim` neo-tree integration, so the configured markers are the ones
  actually used at runtime.
- Fix the clobbering at its source: the `openspec.nvim` plugin (the user's own plugin)
  should not call `neo-tree.setup()` with a partial table that drops prior config — it
  should merge its `filesystem.components` overrides into the existing neo-tree config, or
  the two setups should be consolidated/ordered so the full config wins.
- Revert the earlier, ineffective workaround in `neo-tree.nix` that swapped the `modified`
  glyph to `U+F111` (it never took effect because the whole symbols table was discarded).

## Capabilities

### New Capabilities

- `neotree-config-persistence`: Custom neo-tree `default_component_configs` (notably
  `git_status.symbols`) SHALL remain in effect at runtime even when other plugins
  (e.g. `openspec.nvim`) also call `neo-tree.setup()`.

### Modified Capabilities

<!-- None: no existing spec's requirements change. -->

## Impact

- `packages/mipvim/config/plugins/editor/neo-tree.nix`: revert the `modified` glyph
  workaround; the symbols block remains the source of truth.
- `packages/mipvim/config/plugins/utils/custom_openspec.nix`: the `openspec.setup({ neotree
  = true })` invocation — ordering/consolidation may move here.
- `openspec.nvim` plugin source (`lua/openspec/neotree.lua`, user-maintained): change the
  second `neo-tree.setup()` from a clobbering partial call to a merge, or have it not
  re-run a full setup.
- Affects the neo-tree git_status markers (and any other `default_component_configs`) for
  all files in the tree.
