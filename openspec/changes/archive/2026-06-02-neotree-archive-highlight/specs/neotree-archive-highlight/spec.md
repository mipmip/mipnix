## ADDED Requirements

### Requirement: Archive folder icon override
When neo-tree renders the `archive` folder located at `openspec/changes/archive`, the folder icon SHALL be replaced with 󰀼 (archive box, nerd font codepoint `f003c`) and the icon SHALL use the `NeoTreeArchiveIcon` highlight group with foreground color `#d79921`.

#### Scenario: Archive folder shows custom icon
- **WHEN** neo-tree renders a directory node named `archive` whose parent path ends with `/openspec/changes`
- **THEN** the folder icon is displayed as `󰀼 ` with foreground color `#d79921`

#### Scenario: Non-matching archive folder uses default icon
- **WHEN** neo-tree renders a directory node named `archive` whose parent path does NOT end with `/openspec/changes`
- **THEN** the default folder icon and highlight are used

### Requirement: Archive folder text styling
When neo-tree renders the `archive` folder located at `openspec/changes/archive`, the folder name text SHALL use the `NeoTreeArchiveFolder` highlight group with foreground color `#a89984` and italic styling.

#### Scenario: Archive folder shows styled text
- **WHEN** neo-tree renders a directory node named `archive` whose parent path ends with `/openspec/changes`
- **THEN** the folder name text `archive` is displayed in color `#a89984` with italic font style

### Requirement: Highlight group definitions
The configuration SHALL define two highlight groups via `nvim_set_hl`:
- `NeoTreeArchiveIcon`: `{ fg = "#d79921" }`
- `NeoTreeArchiveFolder`: `{ fg = "#a89984", italic = true }`

#### Scenario: Highlight groups are available
- **WHEN** neovim starts with the mipvim configuration
- **THEN** both `NeoTreeArchiveIcon` and `NeoTreeArchiveFolder` highlight groups are defined and active
