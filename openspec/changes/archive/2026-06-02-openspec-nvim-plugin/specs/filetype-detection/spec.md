## ADDED Requirements

### Requirement: Spec filetype detection
Files matching the path pattern `*/openspec/**/spec.md` SHALL be assigned the filetype `openspec-spec`.

#### Scenario: Main spec file
- **WHEN** neovim opens `openspec/specs/wifi-status/spec.md`
- **THEN** the buffer filetype SHALL be `openspec-spec`

#### Scenario: Delta spec file in change
- **WHEN** neovim opens `openspec/changes/add-auth/specs/user-auth/spec.md`
- **THEN** the buffer filetype SHALL be `openspec-spec`

#### Scenario: Archived spec file
- **WHEN** neovim opens `openspec/changes/archive/2026-06-02-add-auth/specs/user-auth/spec.md`
- **THEN** the buffer filetype SHALL be `openspec-spec`

### Requirement: Proposal filetype detection
Files matching the path pattern `*/openspec/**/proposal.md` SHALL be assigned the filetype `openspec-proposal`.

#### Scenario: Proposal file in change
- **WHEN** neovim opens `openspec/changes/add-auth/proposal.md`
- **THEN** the buffer filetype SHALL be `openspec-proposal`

### Requirement: Design filetype detection
Files matching the path pattern `*/openspec/**/design.md` SHALL be assigned the filetype `openspec-design`.

#### Scenario: Design file in change
- **WHEN** neovim opens `openspec/changes/add-auth/design.md`
- **THEN** the buffer filetype SHALL be `openspec-design`

### Requirement: Tasks filetype detection
Files matching the path pattern `*/openspec/**/tasks.md` SHALL be assigned the filetype `openspec-tasks`.

#### Scenario: Tasks file in change
- **WHEN** neovim opens `openspec/changes/add-auth/tasks.md`
- **THEN** the buffer filetype SHALL be `openspec-tasks`

### Requirement: Non-openspec files unaffected
Files named `spec.md`, `proposal.md`, `design.md`, or `tasks.md` that are NOT under an `openspec/` directory SHALL NOT be assigned openspec filetypes.

#### Scenario: Regular spec.md outside openspec
- **WHEN** neovim opens `docs/spec.md` (not under an `openspec/` directory)
- **THEN** the buffer filetype SHALL remain `markdown`

### Requirement: Treesitter parser activation
When a buffer is assigned the `openspec-spec` filetype, the custom treesitter parser (`openspec_spec`) SHALL be used for syntax highlighting.

#### Scenario: Spec file gets treesitter highlighting
- **WHEN** a buffer with filetype `openspec-spec` is displayed
- **THEN** neovim SHALL use the `openspec_spec` treesitter parser for highlighting

### Requirement: Non-spec filetypes fall back to markdown
Buffers with filetypes `openspec-proposal`, `openspec-design`, and `openspec-tasks` SHALL use the markdown treesitter parser for highlighting in phase 1.

#### Scenario: Proposal uses markdown highlighting
- **WHEN** a buffer with filetype `openspec-proposal` is displayed
- **THEN** neovim SHALL use the `markdown` treesitter parser for highlighting
