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

### Requirement: Neo-tree integration is optional
The neo-tree integration SHALL only activate when `neotree = true` is passed to the plugin setup function. If neo-tree is not installed, the integration SHALL silently skip without errors.

#### Scenario: Setup with neotree enabled
- **WHEN** `require("openspec").setup({ neotree = true })` is called and neo-tree is installed
- **THEN** the archive folder icon and text overrides SHALL be active

#### Scenario: Setup with neotree disabled
- **WHEN** `require("openspec").setup({ neotree = false })` is called
- **THEN** no neo-tree component overrides SHALL be applied

#### Scenario: Neo-tree not installed
- **WHEN** `require("openspec").setup({ neotree = true })` is called but neo-tree is not installed
- **THEN** the plugin SHALL not error and SHALL skip the neo-tree integration
