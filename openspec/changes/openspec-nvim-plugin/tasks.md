## 1. Repository Scaffolding

- [x] 1.1 Create `~/cVibeCoding/openspec.nvim/` directory structure: `lua/openspec/`, `ftdetect/`, `ftplugin/`, `queries/openspec_spec/`, `tree-sitter-openspec-spec/`
- [x] 1.2 Create `lua/openspec/init.lua` with `setup()` function accepting `{ neotree = false }` config

## 2. Filetype Detection

- [x] 2.1 Create `ftdetect/openspec.lua` with `vim.filetype.add()` rules mapping `*/openspec/**/spec.md` → `openspec-spec`, `*/openspec/**/proposal.md` → `openspec-proposal`, `*/openspec/**/design.md` → `openspec-design`, `*/openspec/**/tasks.md` → `openspec-tasks`
- [x] 2.2 Create `ftplugin/openspec-spec.lua` that registers the `openspec_spec` treesitter parser for the buffer
- [x] 2.3 Create `ftplugin/openspec-proposal.lua`, `openspec-design.lua`, `openspec-tasks.lua` that set markdown treesitter parser as fallback

## 3. Treesitter Grammar

- [x] 3.1 Create `tree-sitter-openspec-spec/grammar.js` defining the grammar: `document`, `delta_section`, `delta_header`, `requirement`, `requirement_name`, `requirement_body`, `keyword`, `scenario`, `scenario_name`, `condition`, `assertion`
- [x] 3.2 Create `tree-sitter-openspec-spec/package.json` with tree-sitter build config
- [x] 3.3 Generate the parser: run `tree-sitter generate` to produce `src/` C files
- [x] 3.4 Create `tree-sitter-openspec-spec/test/corpus/` test cases for requirements, scenarios, keywords, delta sections, and bare keyword format
- [x] 3.5 Run `tree-sitter test` and verify all corpus tests pass

## 4. Highlight Queries

- [x] 4.1 Create `queries/openspec_spec/highlights.scm` mapping AST nodes to capture groups: `@type.openspec`, `@string.openspec`, `@function.openspec`, `@keyword.openspec`, `@conditional.openspec`, `@property.openspec`, `@operator.openspec`, `@label.openspec`
- [x] 4.2 Create `queries/openspec_spec/injections.scm` injecting `markdown_inline` into `requirement_body` nodes

## 5. Default Highlight Links

- [x] 5.1 Add default highlight group links in `lua/openspec/init.lua` setup — link each `@*.openspec` group to its standard treesitter counterpart

## 6. Neo-tree Integration

- [x] 6.1 Create `lua/openspec/neotree.lua` with archive folder icon/text component overrides (port from mipnix neo-tree.nix)
- [x] 6.2 Wire neo-tree integration into `setup()` — call `neotree.setup()` when `config.neotree == true` and neo-tree is available, with pcall guard

## 7. Parser Registration

- [x] 7.1 Register the `openspec_spec` parser with nvim-treesitter's parser config in `lua/openspec/init.lua` so the parser can be found and compiled

## 8. Verification

- [ ] 8.1 Install plugin locally, open a spec.md under an openspec directory, and verify filetype is `openspec-spec` with treesitter highlighting active
- [ ] 8.2 Verify neo-tree archive folder shows 󰀼 icon with warm yellow and gray italic text
- [ ] 8.3 Verify non-openspec markdown files are unaffected
<!-- Note: tasks 8.1-8.3 require manual verification in neovim -->
