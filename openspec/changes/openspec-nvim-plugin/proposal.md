## Why

OpenSpec artifacts (`spec.md`, `proposal.md`, `design.md`, `tasks.md`) are structured markdown with domain-specific patterns — normative keywords (SHALL, MUST), requirement/scenario blocks, delta sections (ADDED/MODIFIED/REMOVED) — but neovim treats them as plain markdown. A dedicated plugin with a custom treesitter grammar would give spec files semantic syntax highlighting, and a neo-tree integration would make the openspec directory structure visually navigable.

This is phase 1: treesitter grammar for `spec.md`, filetype detection for all openspec artifact types, and neo-tree archive folder highlighting. Future phases can add grammar support for other artifact types, folding, textobjects, and navigation.

## What Changes

- New standalone neovim plugin (`openspec.nvim`) at `~/cVibeCoding/openspec.nvim/`
- Custom treesitter grammar (`tree-sitter-openspec-spec`) that parses the requirement/scenario structure with keyword nodes, plus markdown injection for prose content
- Filetype detection: files under `*/openspec/` are assigned per-artifact filetypes (`openspec-spec`, `openspec-proposal`, `openspec-design`, `openspec-tasks`)
- Neo-tree integration: archive folder highlight (warm yellow 󰀼 icon, muted gray italic text) bundled as optional plugin feature
- Phase 1 only highlights `openspec-spec` via the treesitter grammar; other filetypes get registered but fall back to markdown highlighting

## Capabilities

### New Capabilities
- `treesitter-grammar`: Custom tree-sitter grammar for openspec spec files — parses requirements, scenarios, keywords (SHALL/MUST/WHEN/THEN), and delta sections into a proper AST
- `filetype-detection`: Automatic filetype assignment for openspec artifacts based on path patterns
- `neotree-integration`: Optional neo-tree component overrides for openspec directory visual treatment
- `spec-highlighting`: Treesitter highlight queries that color spec structure — requirement headings, scenario headings, normative keywords, condition/assertion blocks

### Modified Capabilities

## Impact

- New repository at `~/cVibeCoding/openspec.nvim/` (no changes to mipnix codebase)
- The existing neo-tree archive highlight in `packages/mipvim/config/plugins/editor/neo-tree.nix` can be replaced by the plugin's neo-tree integration once installed
- Dependencies: neovim 0.9+, nvim-treesitter, neo-tree (optional)
