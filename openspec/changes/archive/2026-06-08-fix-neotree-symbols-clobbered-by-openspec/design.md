## Context

mipvim configures neo-tree with custom git_status marker glyphs. In the generated
`init.lua`, the call order is:

```
line ~206:  require("neo-tree").setup({
              default_component_configs = { git_status = { symbols = <9 custom glyphs> } },
              ... })                                  -- user config, CORRECT
line ~411:  require("openspec").setup({ neotree = true })
              └─> openspec/neotree.lua M.setup()
                    └─> require("neo-tree").setup({
                          filesystem = { components = { icon = ..., name = ... } } })
                                                       -- NO default_component_configs
```

Evidence gathered during investigation:

- Byte-level inspection of `init.lua` (via `xxd`, bypassing terminal glyph mangling)
  confirms the user's setup passes `unstaged = U+F06A9` and the full custom symbol set.
- Querying the **live** interactive nvim over its `--server` socket reports the runtime
  git_status symbols as neo-tree **defaults**: `added=U+271A conflict=U+E727
  deleted=U+2716 ignored=U+F474 modified=U+F444 renamed=U+F0055 staged=U+F046
  unstaged=U+F0131 untracked=U+F128` — none of the configured values.
- neo-tree's default `unstaged` glyph `U+F0131` does not render in the active font
  (empirically a box), while the configured `U+F06A9` renders fine. So the visible bug is
  a fallback-to-default, not a font/glyph defect.
- `openspec/neotree.lua` also sets `NeoTreeArchiveIcon` highlight to `#d79921` (orange),
  matching the user's "orange box" description.

`openspec.nvim` (`vimplugin-openspec.nvim`) is the user's own plugin, so a plugin-level
fix is available.

## Goals / Non-Goals

**Goals:**
- The configured neo-tree git_status symbols are the ones actually used at runtime.
- The fix is robust to neo-tree being `setup()` more than once (don't rely on call order
  by luck).
- Remove the dead `modified` glyph workaround that never took effect.

**Non-Goals:**
- Changing the font or any glyph codepoints (not the cause).
- Changing neo-tree itself (the multi-setup-clobber is neo-tree's documented behavior).
- Reworking the openspec neo-tree integration's actual feature (archive icon/components).

## Decisions

### Root cause: neo-tree `setup()` is not cumulative; the second call wins

neo-tree merges each `setup()` call onto **defaults**, not onto the previously-applied
user config. A later partial `setup()` (openspec's `filesystem.components`) therefore
resets `default_component_configs.git_status.symbols` back to defaults.

**Why this is the cause and not a font issue**: the configured `U+F06A9` renders; the
runtime value is the default `U+F0131`; the runtime value provably comes from defaults
(every symbol matches neo-tree defaults, none match the config).

### Preferred fix: openspec.nvim merges instead of clobbering (plugin-level)

Change `openspec/neotree.lua` `M.setup()` so it does **not** call `neo-tree.setup()` with
a standalone partial table. Instead, register its `filesystem.components` overrides
(`icon`, `name`) and the `NeoTreeArchiveIcon`/`NeoTreeArchiveFolder` highlights in a way
that preserves the user's existing config — e.g. read the current `require("neo-tree").config`,
merge the component overrides in, and pass the merged table; or expose the components for
the host to include in its single primary `setup()`.

**Why**: fixes the bug at its source for any consumer of the plugin, and is durable
regardless of init ordering. The plugin is user-maintained, so this is feasible.

**Alternatives considered**:
- *Re-apply symbols after openspec setup* (call neo-tree.setup again with the symbols last)
  — works but is a fragile "last writer wins" race; rejected as the primary fix, acceptable
  as a fallback if the plugin change is deferred.
- *Order openspec.setup BEFORE the main neo-tree.setup* so the user's full config runs last
  — simple, but still relies on ordering and breaks if anything calls setup later.
- *Move git_status.symbols into the openspec neotree setup call* — couples unrelated config
  and hides intent; rejected.

### Revert the dead `modified`-glyph workaround

The earlier change in `neo-tree.nix` swapping `modified` to `U+F111` never had any effect
(the symbols table was being discarded). Revert it so the config reflects intent and the
real fix is unambiguous.

## Risks / Trade-offs

- **[Risk] Plugin change must be deployed with mipvim** → the openspec.nvim source is
  vendored/packaged; editing it requires rebuilding the plugin input. *Mitigation*: if the
  plugin is pinned by flake input, the merge fix lands there and is picked up on rebuild;
  document the path so the implementer edits the right tree.
- **[Risk] Merge semantics in the plugin** → reading and merging `require("neo-tree").config`
  must deep-merge `filesystem.components` without dropping other keys. *Mitigation*: use a
  table deep-merge (e.g. `vim.tbl_deep_extend("force", existing, overrides)`), and verify
  via the live-socket symbol dump after the change.
- **[Trade-off] Plugin-level vs. host-level** → fixing in the plugin is the correct durable
  solution but touches a separate repo/input; the host-level reorder is quicker but
  fragile. Design prefers the plugin fix; tasks allow the reorder as an interim.

## Migration Plan

1. Apply the plugin-level merge fix in `openspec.nvim` (`lua/openspec/neotree.lua`).
2. Revert the `modified` glyph workaround in `neo-tree.nix`.
3. Rebuild mipvim (`up_home`) and restart nvim.
4. Verify via the live nvim socket that `git_status.symbols` equal the configured values
   (notably `unstaged = U+F06A9`), and that a `' M'` file (e.g. `tsconfig.tsbuildinfo`)
   shows the configured marker, not a box.

**Rollback**: revert the plugin and neo-tree.nix changes; rebuild.

## Open Questions

- Is `openspec.nvim` consumed as a flake input (pinned store path) or a local path in the
  monorepo? This determines where the plugin edit is made and how it is rebuilt. (To be
  confirmed at implementation time.)
