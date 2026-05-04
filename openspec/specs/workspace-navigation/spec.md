# Workspace Navigation

## ADDED Requirements

### Requirement: show-occupied-workspaces

The bar SHALL display a button for each hyprland workspace that has at least one client (window). Empty workspaces SHALL NOT be shown. The workspace list SHALL react to client-level changes (open, close, move) in addition to workspace-level changes (added, removed).

#### Scenario: workspace with windows is visible

WHEN a workspace has one or more clients
THEN the bar SHALL display a button for that workspace

#### Scenario: empty workspace is hidden

WHEN a workspace has zero clients
THEN the bar SHALL NOT display a button for that workspace

#### Scenario: workspace becomes empty

WHEN the last client is removed from a workspace
THEN the button for that workspace SHALL be removed from the bar

#### Scenario: window opens in empty workspace

WHEN a client is added to a previously empty workspace
THEN a button for that workspace SHALL appear in the bar

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
