## 1. Confirm the plugin source location

- [x] 1.1 Determine how `openspec.nvim` is consumed. Result: mipvim fetches `speclib/openspec.nvim` from GitHub (pinned rev+hash in `custom_openspec.nix`); the user owns this repo with a colocated jj/git working copy at `~/cVibeCoding/openspec.nvim` (working copy was at the pinned rev `3b729e9`). The plugin-level fix is therefore viable: fix upstream, push, re-pin.

## 2. Fix the clobbering at the source (preferred)

- [x] 2.1 In `openspec.nvim` `lua/openspec/neotree.lua` `M.setup()`, stopped calling `require("neo-tree").setup({ filesystem = { components = ... } })` with a bare partial table
- [x] 2.2 Now deep-merges the openspec `filesystem.components` into neo-tree's existing config: `require("neo-tree").setup(vim.tbl_deep_extend("force", require("neo-tree").config or {}, { filesystem = { components = ... } }))`, preserving the user's `default_component_configs`. Committed as `00fc1d55` and pushed to `speclib/openspec.nvim` main; mipnix pin in `custom_openspec.nix` updated to that rev + new hash.

## 3. Clean up the host config

- [x] 3.1 No revert needed. The `modified = U+F111` glyph is a valid, verified-rendering glyph and a sensible "modified" marker; the original value was blank/empty. The real fix was the openspec clobber (Task 2), not the glyph — so U+F111 is kept intentionally.
- [x] 3.2 Confirmed `packages/mipvim/config/plugins/utils/custom_openspec.nix` still calls `require("openspec").setup({ neotree = true })`.

## 4. Build and verify

- [x] 4.1 Rebuild mipvim with `up_home` and restart nvim
- [x] 4.2 Query the live nvim over its `--server` socket and confirm `default_component_configs.git_status.symbols` equal the configured values (notably `unstaged = U+F06A9`, not the default `U+F0131`)
- [x] 4.3 Open a repo with a `' M'` file (e.g. `tsconfig.tsbuildinfo`) in neo-tree and confirm the marker renders as the configured glyph, not a box
- [x] 4.4 Confirm the openspec neo-tree features (archive icon/components, `NeoTreeArchiveIcon` highlight) still work after the merge change
