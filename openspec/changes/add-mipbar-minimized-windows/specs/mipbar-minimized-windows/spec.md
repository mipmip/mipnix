# mipbar Minimized Windows

## ADDED Requirements

### Requirement: minimized-windows-indicator

mipbar SHALL display an indicator in the bar's `end` cluster that reveals windows
minimized to the `special:minimized` workspace. The indicator SHALL be hidden
when no windows are minimized, and SHALL show a count when one or more are.

#### Scenario: nothing minimized

- **WHEN** no windows are in the `special:minimized` workspace
- **THEN** the indicator SHALL NOT be visible in the bar

#### Scenario: one or more minimized

- **WHEN** one or more windows are in the `special:minimized` workspace
- **THEN** the indicator SHALL be visible and SHALL show the count of minimized
  windows

#### Scenario: live update on minimize/restore

- **WHEN** a window is minimized or restored (Hyprland client/workspace state
  changes)
- **THEN** the indicator's visibility and count SHALL update without requiring
  user interaction

### Requirement: minimized-windows-list

Clicking the indicator SHALL open a popover listing each minimized window with
enough information to identify it (application icon and window title).

#### Scenario: popover lists minimized windows

- **WHEN** the indicator is visible and the user opens its popover
- **THEN** the popover SHALL show one row per minimized window, each with the
  window's app icon and title

### Requirement: restore-window-to-current-workspace

The popover SHALL let the user restore a minimized window. Restoring SHALL move
the window to the **current** (active) workspace and focus it.

#### Scenario: restore a single window

- **WHEN** the user activates a window's row in the popover
- **THEN** that window SHALL be moved to the current workspace and focused, and
  SHALL no longer be in the `special:minimized` workspace

#### Scenario: restore all

- **WHEN** the user activates the "Restore all" action
- **THEN** every window in `special:minimized` SHALL be moved to the current
  workspace

#### Scenario: indicator hides after the last restore

- **WHEN** the last minimized window is restored
- **THEN** the indicator SHALL become hidden again (no minimized windows remain)
