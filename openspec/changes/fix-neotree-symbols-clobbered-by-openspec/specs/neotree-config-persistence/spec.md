# Neo-tree Config Persistence

## ADDED Requirements

### Requirement: configured-git-symbols-used-at-runtime

The neo-tree `git_status` marker symbols configured in mipvim SHALL be the symbols actually used at runtime, not neo-tree's built-in defaults.

#### Scenario: runtime symbols match configuration

- **WHEN** nvim has finished loading its configuration
- **THEN** neo-tree's runtime `default_component_configs.git_status.symbols` SHALL equal the configured values (e.g. `unstaged` SHALL be the configured `U+F06A9`, not the default `U+F0131`)

#### Scenario: modified-unstaged file shows configured marker

- **WHEN** the file tree displays a file with git status `' M'` (modified, unstaged)
- **THEN** the rendered git marker SHALL use the configured glyphs and SHALL NOT render as a box/tofu

### Requirement: symbols-survive-secondary-setup

The configured neo-tree `default_component_configs` SHALL survive additional `neo-tree.setup()` calls made by other plugins (e.g. `openspec.nvim`) that do not themselves pass `default_component_configs`.

#### Scenario: openspec neotree integration enabled

- **WHEN** `openspec.nvim` is configured with `neotree = true` and applies its filesystem component overrides
- **THEN** the user's `git_status.symbols` SHALL remain in effect and SHALL NOT revert to neo-tree defaults

#### Scenario: openspec component overrides still applied

- **WHEN** the openspec neo-tree integration is active alongside the user's symbol configuration
- **THEN** both the openspec `filesystem.components` overrides and the user's `git_status.symbols` SHALL be applied together
