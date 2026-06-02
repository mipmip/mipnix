## Context

Neo-tree supports per-source component overrides via `filesystem.components`. Each component (e.g., `name`, `icon`) is a Lua function `(config, node, state) -> table` that returns `{ text, highlight }`. By overriding these two components, we can intercept rendering for a specific folder without affecting any other nodes.

The neovim config is built with nixvim, which passes `settings` through to the neo-tree `setup()` call. Lua functions are injected via `lib.nixvim.mkRaw`.

## Goals / Non-Goals

**Goals:**
- Visually distinguish the `archive` folder under `openspec/changes/` with a custom icon and color
- Keep the change contained to a single file (`neo-tree.nix`)

**Non-Goals:**
- Highlighting other special folders (specs, changes, etc.)
- Making the highlight rules configurable or extensible
- Changing archive folder behavior (expand, filter, etc.)

## Decisions

### Override `filesystem.components.name` and `filesystem.components.icon`

Both components delegate to the default implementation from `neo-tree.sources.common.components`, then conditionally override `highlight` and `text` when the node matches. This preserves all default behavior for non-matching nodes.

**Alternative considered**: Using `event_handlers` with `vim.fn.matchadd()` on buffer text. Rejected because it operates on rendered text rather than the tree structure, making parent-path detection fragile.

### Match condition: `node.name == "archive"` and parent path ends with `/openspec/changes`

Uses `node:get_parent_id()` which returns the absolute filesystem path of the parent. A `string.match` with pattern `/openspec/changes$` ensures only the specific archive folder is affected.

### Two highlight groups: `NeoTreeArchiveIcon` and `NeoTreeArchiveFolder`

Separate groups allow the icon (`#d79921` warm yellow) and text (`#a89984` muted gray, italic) to have independent styling. Defined via `extraConfigLua` using `nvim_set_hl`.

## Risks / Trade-offs

- **[Neo-tree internal API]** `node:get_parent_id()` and the common components module path are not part of a public API contract. Neo-tree updates could break this. Mitigation: these APIs have been stable for years; pin neo-tree version in nixvim if needed.
- **[Highlight group ordering]** If the colorscheme loads after `extraConfigLua`, it could clear custom highlight groups. Mitigation: neo-tree highlight groups are typically not touched by colorschemes; gruvbox doesn't define `NeoTreeArchive*`.
