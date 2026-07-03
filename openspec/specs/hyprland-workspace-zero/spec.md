# Hyprland Workspace Zero

## Purpose

Workspace 0 SHALL be a first-class, self-consistent workspace: the `MOD+0` keybind, the
`workspaces.conf` declaration, and the mipbar "0" button SHALL all refer to the same
workspace id (0), and the mipbar "0" button SHALL show app icons for windows on it just
like every other workspace button.

## Requirements

### Requirement: workspace-zero-identity-consistency

The workspace reachable via the `MOD+0` keybind, the workspace declared in `workspaces.conf`, and the workspace previewed by the mipbar "0" button SHALL all refer to the same workspace id (0).

#### Scenario: switching to workspace 0

- **WHEN** the user presses `MOD+0`
- **THEN** Hyprland SHALL switch to workspace id 0 (not workspace id 10)

#### Scenario: moving a window to workspace 0

- **WHEN** the user presses `MOD+SHIFT+0` with a focused window
- **THEN** the window SHALL be moved to workspace id 0 (not workspace id 10)

### Requirement: workspace-zero-shows-app-icons

When applications are running on workspace 0, the mipbar workspace button for "0" SHALL
display their app icons, consistent with every other workspace button.

#### Scenario: app running on workspace 0

- **WHEN** one or more windows are present on workspace id 0
- **THEN** the mipbar "0" workspace button SHALL display one icon per window

#### Scenario: empty workspace 0

- **WHEN** workspace id 0 has no windows
- **THEN** the mipbar "0" workspace button SHALL display the workspace id with no app
  icons (consistent with other empty workspaces)
