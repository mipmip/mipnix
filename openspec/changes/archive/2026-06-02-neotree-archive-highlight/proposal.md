## Why

The `openspec/changes/archive` folder in neo-tree looks identical to every other directory, making it hard to visually distinguish at a glance. A custom icon and muted color treatment would signal "these are completed, filed-away changes" without requiring the user to read the path.

## What Changes

- Override the neo-tree `name` and `icon` filesystem components to detect when a folder named `archive` sits under `openspec/changes/`
- Render that folder with the 󰀼 (archive box) icon in warm yellow (`#d79921`) instead of the default folder icon
- Render the folder name text in muted gray (`#a89984`) with italic styling
- Define two new highlight groups: `NeoTreeArchiveIcon` and `NeoTreeArchiveFolder`

## Capabilities

### New Capabilities
- `neotree-archive-highlight`: Custom neo-tree rendering for the openspec archive folder with distinct icon and color treatment

### Modified Capabilities

## Impact

- `packages/mipvim/config/plugins/editor/neo-tree.nix` — add `filesystem.components` overrides using `mkRaw` Lua functions
- Same file or a companion — add `extraConfigLua` block defining the two highlight groups
- No dependencies added; uses neo-tree's built-in component override system
