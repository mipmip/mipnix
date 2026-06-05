## 1. Confirm the plugin source location

- [ ] 1.1 Determine how `openspec.nvim` (`vimplugin-openspec.nvim`) is consumed — flake input (pinned) vs. local path — so the edit lands in the right tree and is picked up by `up_home`

## 2. Fix the clobbering at the source (preferred)

- [ ] 2.1 In `openspec.nvim` `lua/openspec/neotree.lua` `M.setup()`, stop calling `require("neo-tree").setup({ filesystem = { components = ... } })` with a partial table that drops prior config
- [ ] 2.2 Instead, deep-merge the openspec `filesystem.components` (and highlights) into neo-tree's existing config (e.g. read `require("neo-tree").config`, `vim.tbl_deep_extend("force", existing, overrides)`, then setup), preserving the user's `default_component_configs`

## 3. Clean up the host config

- [ ] 3.1 Revert the earlier `modified` glyph workaround in `packages/mipvim/config/plugins/editor/neo-tree.nix` (the U+F111 swap that never took effect)
- [ ] 3.2 Confirm `packages/mipvim/config/plugins/utils/custom_openspec.nix` still calls `openspec.setup({ neotree = true })` as intended

## 4. Build and verify

- [ ] 4.1 Rebuild mipvim with `up_home` and restart nvim
- [ ] 4.2 Query the live nvim over its `--server` socket and confirm `default_component_configs.git_status.symbols` equal the configured values (notably `unstaged = U+F06A9`, not the default `U+F0131`)
- [ ] 4.3 Open a repo with a `' M'` file (e.g. `tsconfig.tsbuildinfo`) in neo-tree and confirm the marker renders as the configured glyph, not a box
- [ ] 4.4 Confirm the openspec neo-tree features (archive icon/components, `NeoTreeArchiveIcon` highlight) still work after the merge change
