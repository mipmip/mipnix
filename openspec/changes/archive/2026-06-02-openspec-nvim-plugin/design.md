## Context

OpenSpec artifacts are markdown files with consistent structural conventions. Spec files (`spec.md`) have the richest structure: `### Requirement:` headings, `#### Scenario:` blocks with WHEN/THEN conditions, normative keywords (SHALL, MUST, SHALL NOT), and delta section headers (ADDED/MODIFIED/REMOVED/RENAMED). Other artifact types (proposal, design, tasks) have lighter structures.

The plugin will be a standalone neovim plugin at `~/cVibeCoding/openspec.nvim/`, installable via any plugin manager. Phase 1 focuses on the treesitter grammar for spec files, filetype detection, and neo-tree integration.

## Goals / Non-Goals

**Goals:**
- Custom treesitter grammar that parses spec.md into a semantic AST (requirements, scenarios, keywords, delta sections)
- Markdown injection inside prose content so inline formatting (bold, code, links) still works
- Filetype detection for all four openspec artifact types based on path patterns
- Neo-tree archive folder visual treatment bundled as optional feature
- Plugin setup function with sensible defaults

**Non-Goals:**
- Treesitter grammars for proposal/design/tasks (phase 2+)
- Folding, textobjects, or navigation commands (phase 2+)
- LSP or diagnostics (phase 2+)
- Statusline integration (phase 2+)

## Decisions

### Standalone treesitter grammar with markdown injection

The grammar (`tree-sitter-openspec-spec`) parses the spec structure into proper AST nodes. Prose content within requirement bodies and scenario descriptions gets markdown injected via `injections.scm`.

**AST structure:**

```
(document
  (title)?                          ← # Title (optional)
  (delta_section                    ← ## ADDED/MODIFIED/REMOVED/RENAMED Requirements
    (delta_header)
    (requirement                    ← ### Requirement: <name>
      (requirement_name)
      (requirement_body             ← prose with keywords
        (keyword)*                  ← SHALL, MUST, SHALL NOT, MUST NOT
      )
      (scenario                     ← #### Scenario: <name>
        (scenario_name)
        (condition)*                ← WHEN/AND lines
        (assertion)*                ← THEN/AND lines
      )*
    )*
  )*
  (requirement)*                    ← requirements without delta section wrapper
)
```

**Alternative considered:** Extending the markdown treesitter grammar via custom queries. Rejected because you can't add new node types to an existing grammar's AST — you'd be limited to regex-based `#match?` predicates in highlight queries, which can't express the hierarchical requirement/scenario structure.

**Alternative considered:** Pure `vim.fn.matchadd()` overlays. Rejected because it operates on rendered text, not structure — can't distinguish a `SHALL` in a requirement body from `SHALL` in a random comment.

### Per-artifact filetypes via path-based detection

```
Pattern                                    Filetype
*/openspec/**/spec.md                   → openspec-spec
*/openspec/**/proposal.md               → openspec-proposal
*/openspec/**/design.md                 → openspec-design
*/openspec/**/tasks.md                  → openspec-tasks
```

Detection uses `vim.filetype.add()` with filename + path patterns. The `openspec-spec` filetype triggers the custom treesitter parser; others fall back to markdown with the filetype set (ready for future per-type features).

**Alternative considered:** Content-based detection (scan for `### Requirement:`). Rejected as slower and less reliable — the path convention is already well-established.

### Optional neo-tree integration via setup config

The plugin exposes `require("openspec").setup({ neotree = true })`. When enabled, it overrides neo-tree's `filesystem.components.icon` and `filesystem.components.name` to highlight the archive folder under `openspec/changes/`. The logic is identical to the existing mipnix implementation.

Neo-tree is a soft dependency — the plugin loads fine without it. If `neotree = true` but neo-tree isn't installed, it silently skips.

### Highlight groups and color scheme

The plugin defines highlight groups linked to standard treesitter capture groups, so colors adapt to any colorscheme:

| Highlight Group | Default Link | Purpose |
|----------------|-------------|---------|
| `@keyword.openspec` | `@keyword` | SHALL, MUST, SHALL NOT, MUST NOT |
| `@type.openspec` | `@type` | `### Requirement:` prefix |
| `@function.openspec` | `@function` | `#### Scenario:` prefix |
| `@conditional.openspec` | `@conditional` | WHEN |
| `@property.openspec` | `@property` | THEN |
| `@operator.openspec` | `@operator` | AND |
| `@label.openspec` | `@label` | Delta section headers (ADDED, MODIFIED, etc.) |
| `@string.openspec` | `@string` | Requirement name, scenario name |
| `NeoTreeArchiveIcon` | — | `#d79921` (hardcoded, gruvbox yellow) |
| `NeoTreeArchiveFolder` | — | `#a89984` italic (hardcoded, gruvbox gray) |

Users can override any group in their colorscheme. The neo-tree groups stay hardcoded as they're meant for a specific visual effect.

## Risks / Trade-offs

- **[Treesitter grammar maintenance]** Custom grammars need to be compiled for each platform. Users install via nvim-treesitter's `:TSInstall` or the plugin bundles pre-compiled parsers. → Mitigation: Register the grammar with nvim-treesitter's parser config so `:TSInstall openspec_spec` works. Provide build instructions.

- **[Spec format evolution]** If the openspec spec format changes, the grammar breaks. → Mitigation: The format is stable and controlled by the same author. Version the grammar alongside the openspec CLI.

- **[Markdown injection completeness]** Injecting markdown into prose nodes may not capture all edge cases (nested code blocks, HTML). → Mitigation: Use `markdown_inline` injection which handles inline formatting (bold, code, links) — block-level markdown features in spec prose are uncommon.

- **[Neo-tree API stability]** The component override relies on `neo-tree.sources.common.components` internals. → Mitigation: Same risk as the standalone implementation; these APIs have been stable for years.
