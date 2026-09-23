## ADDED Requirements

### Requirement: Cross-repo beans index available as a tmux popup

pim's tmux SHALL provide a keybinding that opens the `beandex` cross-repo beans index
in a popup, complementing the existing single-repo `beans tui` popup (`prefix + B`).

#### Scenario: Opening the index

- **WHEN** pim presses `prefix + D` in tmux
- **THEN** a popup SHALL open running `beandex`, listing every repo under the
  configured scan paths that has beans tickets
- **AND** selecting a repo (`Enter`) SHALL launch `beans tui` for that repo and return
  to the index when it quits

### Requirement: beandex scan configuration is managed declaratively

The home-manager configuration SHALL provide `~/.config/beandex/config.yaml`, because
`beandex` refuses to run without a config file, so the popup never opens onto a config
error.

#### Scenario: Config present after switch

- **WHEN** the `cli-full` home-manager generation is activated
- **THEN** `~/.config/beandex/config.yaml` SHALL exist and declare a single scan path
  of `~` with `max_depth: 2`, covering pim's `~/<short>.<owner>/<repo>` layout
- **AND** running `beandex` SHALL list repos rather than exiting with a config error
