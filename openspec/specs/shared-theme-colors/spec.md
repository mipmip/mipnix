# shared-theme-colors Specification

## Purpose
TBD - created by archiving change centralize-theme-colors. Update Purpose after archive.
## Requirements
### Requirement: Shared color definitions
The system SHALL provide a single colors definition file that contains all shared theme color values. This file SHALL be a plain Nix attrset importable by both flake-level and module-level code.

#### Scenario: Colors file defines active and inactive backgrounds
- **WHEN** the colors file is evaluated
- **THEN** it SHALL contain `bg.active` set to `"#000000"` and `bg.inactive` set to `"#292f32"`

### Requirement: Home-manager theme options
The system SHALL provide a home-manager module under `modules/themes/` that exposes color values as `config.mip.theme.colors` options, with defaults sourced from the shared colors file. The module SHALL be auto-discovered by import-tree.

#### Scenario: Theme options available in home-manager modules
- **WHEN** a home-manager module accesses `config.mip.theme.colors.bg.inactive`
- **THEN** it SHALL receive the value `"#292f32"`

### Requirement: Tmux uses shared colors
The tmux module SHALL read `window-active-style` and `window-style` background colors from `config.mip.theme.colors` instead of hardcoded hex values.

#### Scenario: Tmux inactive pane background matches shared config
- **WHEN** tmux configuration is generated
- **THEN** `window-active-style` SHALL use `config.mip.theme.colors.bg.active` and `window-style` SHALL use `config.mip.theme.colors.bg.inactive`

### Requirement: Neovim inactive window dimming
The nixvim configuration SHALL set the `NormalNC` highlight group background to the shared inactive color, passed via `extraSpecialArgs`.

#### Scenario: Inactive neovim windows show dimmed background
- **WHEN** a neovim window loses focus
- **THEN** its background SHALL change to the `bg.inactive` color (`#292f32`)

#### Scenario: Active neovim window stays transparent
- **WHEN** a neovim window has focus
- **THEN** its background SHALL remain transparent (inheriting the terminal background)

### Requirement: Colors passed to nixvim
The flake SHALL pass the shared colors to the nixvim module via `extraSpecialArgs` so that nixvim config files can access the color values.

#### Scenario: Nixvim config receives colors
- **WHEN** a nixvim config file declares `mipColors` as a module argument
- **THEN** it SHALL receive the shared colors attrset with `bg.active` and `bg.inactive`

