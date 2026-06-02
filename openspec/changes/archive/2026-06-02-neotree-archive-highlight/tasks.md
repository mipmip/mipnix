## 1. Highlight Groups

- [x] 1.1 Add `extraConfigLua` block to `neo-tree.nix` defining `NeoTreeArchiveIcon` (`fg=#d79921`) and `NeoTreeArchiveFolder` (`fg=#a89984`, `italic=true`) highlight groups

## 2. Component Overrides

- [x] 2.1 Add `filesystem.components.icon` override via `mkRaw` — delegate to default, then swap to `󰀼 ` with `NeoTreeArchiveIcon` highlight when node matches `archive` under `openspec/changes`
- [x] 2.2 Add `filesystem.components.name` override via `mkRaw` — delegate to default, then apply `NeoTreeArchiveFolder` highlight when node matches

## 3. Verification

- [ ] 3.1 Rebuild mipvim and confirm the archive folder renders with custom icon and colors in neo-tree
