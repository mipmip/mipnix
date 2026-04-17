## ADDED Requirements

### Requirement: Interactive role selection during host creation
The system SHALL present an interactive multi-select menu of available roles when creating a new host, allowing the user to compose the host's functionality from predefined roles.

#### Scenario: Roles auto-discovered from filesystem
- **WHEN** user runs `./RUNME.sh new_host` and reaches the role selection step
- **THEN** the system scans `modules/ROLES/*.nix` for files whose module name starts with `role-`, and presents them as selectable options via `gum choose --no-limit`

#### Scenario: User selects multiple roles
- **WHEN** user selects `role-devbox` and `role-desktop-pim` from the role menu
- **THEN** the generated `configuration.nix` imports block includes both `role-devbox` and `role-desktop-pim` alongside `system-default`

#### Scenario: User selects no roles
- **WHEN** user selects no optional roles
- **THEN** the generated `configuration.nix` imports block contains only `system-default`

### Requirement: Nebula triggered by role selection
The system SHALL call `new_nebula_node` automatically when `role-nebula-node` is among the selected roles, replacing the previous separate nebula confirmation prompt.

#### Scenario: Nebula role selected
- **WHEN** user selects `role-nebula-node` in the role selector
- **THEN** the system calls `new_nebula_node` after creating the host files

#### Scenario: Nebula role not selected
- **WHEN** user does not select `role-nebula-node`
- **THEN** the system does not prompt for or create nebula certificates
