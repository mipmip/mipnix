## MODIFIED Requirements

### Requirement: workspace-zero-identity-consistency

The workspace labelled "0" SHALL be Hyprland workspace **id 10**. The `MOD+0`
keybind, the `MOD+SHIFT+0` keybind, the `workspaces.conf` declaration, the
`workspace-monitor-rehome` laptop-workspace set, and the mipbar "0" button SHALL all
refer to that same id.

Hyprland workspace ids begin at 1; there is no addressable workspace id 0, so a
dispatch or declaration naming `0` is inert. "0" is therefore a *display label*
only, and SHALL NOT be used as a workspace id anywhere in the configuration.

#### Scenario: switching to workspace 0

- **WHEN** the user presses `MOD+0`
- **THEN** Hyprland SHALL switch to workspace id 10 (the workspace labelled "0")

#### Scenario: moving a window to workspace 0

- **WHEN** the user presses `MOD+SHIFT+0` with a focused window
- **THEN** the window SHALL be moved to workspace id 10

#### Scenario: no configuration names workspace id 0

- **WHEN** the Hyprland configuration and the mipbar workspace list are inspected
- **THEN** no keybind, workspace declaration, reconciliation set, or bar lookup SHALL
  reference workspace id `0`

#### Scenario: the declared workspace actually exists

- **WHEN** a window is placed on the workspace labelled 0
- **THEN** `hyprctl workspaces` SHALL report a workspace with id 10 containing that
  window (previously no workspace was created at all, because id 0 is not
  addressable)

### Requirement: workspace-zero-shows-app-icons

When applications are running on the workspace labelled "0" (id 10), the mipbar
workspace button for "0" SHALL display their app icons, consistent with every other
workspace button.

#### Scenario: app running on workspace 0

- **WHEN** one or more windows are present on workspace id 10
- **THEN** the mipbar "0" workspace button SHALL display one icon per window

#### Scenario: empty workspace 0

- **WHEN** workspace id 10 has no windows
- **THEN** the mipbar "0" workspace button SHALL display the label "0" with no app
  icons (consistent with other empty workspaces)

## ADDED Requirements

### Requirement: workspace-label-distinct-from-id

The mipbar workspace list SHALL carry a display label separately from the workspace
id it looks up and dispatches to, so a workspace whose label differs from its id
cannot silently query the wrong workspace.

#### Scenario: label and id differ

- **WHEN** the workspace list entry for the button labelled "0" is evaluated
- **THEN** its id SHALL be 10 and its label SHALL be "0", the client lookup SHALL use
  the id, and the rendered text SHALL use the label

#### Scenario: clicking the button dispatches the id

- **WHEN** the user clicks the mipbar button labelled "0"
- **THEN** mipbar SHALL dispatch `workspace 10`, not `workspace 0`

#### Scenario: laptop grouping follows the id

- **WHEN** mipbar decides which workspace buttons receive the laptop accent and the
  group separator
- **THEN** the laptop set SHALL be the workspace ids 8, 9, and 10
