## MODIFIED Requirements

### Requirement: workspace-visibility
The workspace indicator SHALL always display workspaces 1-9 and 0, regardless of whether they contain windows.

#### Scenario: all workspaces visible
- **WHEN** mipbar starts
- **THEN** workspaces 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 SHALL all be visible in this order

#### Scenario: empty workspace appearance
- **WHEN** a workspace has no windows
- **THEN** it SHALL display the workspace number only (no app icons)

#### Scenario: occupied workspace appearance
- **WHEN** a workspace has windows
- **THEN** it SHALL display the workspace number and app icons for each window

## ADDED Requirements

### Requirement: workspace-monitor-groups
The workspace indicator SHALL visually separate external monitor workspaces (1-7) from laptop workspaces (8, 9, 0).

#### Scenario: group separator
- **WHEN** all workspaces are displayed
- **THEN** there SHALL be a visual separator between workspace 7 and workspace 8

### Requirement: laptop-workspace-accent
Laptop workspaces (8, 9, 0) SHALL have a distinct accent color to differentiate them from external monitor workspaces.

#### Scenario: laptop accent in dark mode
- **WHEN** dark mode is active
- **THEN** laptop workspaces SHALL have a cool-toned tinted background

#### Scenario: laptop accent in light mode
- **WHEN** light mode is active
- **THEN** laptop workspaces SHALL have a cool-toned tinted background with appropriate contrast

#### Scenario: accent persists when laptop-only
- **WHEN** only the laptop display is connected
- **THEN** laptop workspaces (8, 9, 0) SHALL still show the accent color

### Requirement: light-mode-workspace-background
The workspace container SHALL have visible background contrast in light mode, matching the dark mode behavior.

#### Scenario: light mode background
- **WHEN** light mode is active
- **THEN** the workspace container background SHALL be visually distinct from the bar background
