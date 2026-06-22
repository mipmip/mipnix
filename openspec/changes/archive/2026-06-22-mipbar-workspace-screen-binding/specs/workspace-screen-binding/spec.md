## ADDED Requirements

### Requirement: monitor-underline-indicator
Every workspace button SHALL display an underline indicator coloured by the
accent of the monitor the workspace is currently bound to. The underline SHALL
be present regardless of workspace state (empty, occupied, or active).

#### Scenario: underline shown on every workspace
- **WHEN** the bar renders the workspace list
- **THEN** each workspace button SHALL show an underline bar (14×2.5px, radius 2px) below its number/icon row

#### Scenario: underline colour matches bound monitor
- **WHEN** a workspace is bound to a monitor with a given accent colour
- **THEN** that workspace's underline SHALL be filled with that accent colour

#### Scenario: empty workspace still shows underline
- **WHEN** a workspace has no windows
- **THEN** it SHALL still show its monitor underline (the indicator is independent of occupancy)

#### Scenario: button layout is a vertical stack
- **WHEN** a workspace button renders
- **THEN** its number/app-icon row and its underline row SHALL be stacked vertically with a 4px gap

### Requirement: monitor-accent-resolution
The bar SHALL resolve a deterministic accent colour per monitor name, stable
across reloads.

#### Scenario: accent from user config map
- **WHEN** a monitor name has an entry in the user accent config map
- **THEN** that configured colour SHALL be used as the monitor's accent

#### Scenario: accent fallback for unmapped monitor
- **WHEN** a monitor name has no config entry
- **THEN** an accent SHALL be derived deterministically from a hash of the monitor name
- **AND** the same name SHALL always yield the same accent across reloads

#### Scenario: dark-mode accent variant
- **WHEN** dark mode is active
- **THEN** the accent SHALL be brightened relative to the light-mode accent

### Requirement: reactive-binding-updates
The underline indicators SHALL update when Hyprland reports monitors or
workspace-to-monitor bindings changing.

#### Scenario: workspace moved to another monitor
- **WHEN** a workspace is moved from one monitor to another
- **THEN** that workspace's underline colour SHALL update to the new monitor's accent

#### Scenario: monitor connected
- **WHEN** a monitor is connected
- **THEN** the bar SHALL recompute workspace-to-monitor bindings and underline colours

#### Scenario: monitor disconnected
- **WHEN** a monitor is disconnected
- **THEN** the bar SHALL recompute workspace-to-monitor bindings and underline colours

### Requirement: right-click-screen-picker
Secondary-clicking a workspace button SHALL open a popover that lists every
connected monitor as a selectable row.

#### Scenario: popover opens on secondary click
- **WHEN** the user presses the secondary (right) mouse button on a workspace button
- **THEN** a popover anchored to that button SHALL open

#### Scenario: secondary click does not switch workspace
- **WHEN** the user secondary-clicks a workspace button
- **THEN** the bar SHALL NOT dispatch a workspace switch (that remains the primary-click behaviour)

#### Scenario: one row per connected monitor
- **WHEN** the picker is open
- **THEN** it SHALL show exactly one row per connected monitor

#### Scenario: header shows target workspace
- **WHEN** the picker opens for workspace N
- **THEN** the header SHALL identify workspace N as the binding target

### Requirement: monitor-row-details
Each monitor row in the picker SHALL display the monitor's identity and
connection details.

#### Scenario: row shows model and spec line
- **WHEN** a monitor row renders
- **THEN** it SHALL show the monitor model (Hyprland `description`) and a spec line of the form `SIZE · RES · REFRESH`

#### Scenario: row shows port chip and connector tag
- **WHEN** a monitor row renders
- **THEN** it SHALL show a port chip (port type, accent-coloured) and the connector tag (e.g. `DP-1`) in monospace

#### Scenario: row shows a device image by type
- **WHEN** the monitor is an internal display (eDP/LVDS)
- **THEN** the row SHALL show a laptop device illustration
- **WHEN** the monitor is external
- **THEN** the row SHALL show a monitor device illustration

#### Scenario: current monitor is marked
- **WHEN** a monitor row corresponds to the workspace's current monitor
- **THEN** that row SHALL be marked as current (CURRENT pill and accent border)

### Requirement: live-rebind-action
Selecting a monitor row in the picker SHALL rebind the workspace to that monitor
at runtime via the Hyprland service.

#### Scenario: rebind dispatch on selection
- **WHEN** the user selects a monitor row for workspace N
- **THEN** the bar SHALL issue `dispatch moveworkspacetomonitor N <NAME>` via the AGS hyprland service

#### Scenario: popover closes after selection
- **WHEN** a monitor row is selected
- **THEN** the popover SHALL close and the selected row SHALL be reflected as current

#### Scenario: binding is runtime-only
- **WHEN** a workspace is rebound through the picker
- **THEN** the change SHALL be applied at runtime only
- **AND** no persistent Hyprland configuration SHALL be written by this capability
