# Workspace Navigation

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

#### Scenario: client added to existing workspace triggers update

WHEN a client is added to a workspace that already has clients
THEN the workspace button SHALL re-render to reflect the updated client list

#### Scenario: client moved between workspaces triggers update

WHEN a client moves from one workspace to another
THEN both the source and destination workspace buttons SHALL re-render to reflect their updated client lists

### Requirement: group-by-monitor

Workspaces SHALL be displayed grouped by monitor. Each monitor group SHALL be visually separated.

#### Scenario: workspaces from multiple monitors

WHEN workspaces exist on both DP-3 and eDP-1
THEN the bar SHALL show workspaces grouped by their monitor assignment
AND groups SHALL be visually distinguishable

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

### Requirement: show-on-all-bars

Every bar instance (one per monitor) SHALL show workspaces from all monitors, not just its own.

#### Scenario: laptop bar shows external workspaces

WHEN viewing the bar on eDP-1
THEN workspaces from DP-3 SHALL also be visible

### Requirement: active-workspace-indicator

The currently focused workspace SHALL be visually distinguished with a pill-style highlight.

#### Scenario: workspace is focused

WHEN a workspace is the focused workspace
THEN its button SHALL display a pill-style highlight (distinct background)

#### Scenario: workspace loses focus

WHEN a different workspace becomes focused
THEN the previously focused workspace button SHALL lose its pill-style highlight

### Requirement: click-to-switch

Clicking a workspace button SHALL switch the focused workspace to that workspace.

#### Scenario: user clicks workspace button

WHEN the user clicks a workspace button
THEN hyprland SHALL switch focus to that workspace

### Requirement: positioned-after-launcher

The workspace buttons SHALL be positioned immediately after the app launcher button in the start section of the bar.

#### Scenario: layout order

WHEN the bar is rendered
THEN the start section SHALL contain the app launcher button followed by the workspace buttons

### Requirement: sorted-by-id

Workspace buttons within each monitor group SHALL be sorted by workspace ID in ascending order.

#### Scenario: workspace order

WHEN multiple workspaces are visible for a monitor
THEN they SHALL be ordered by ascending workspace ID
