## ADDED Requirements

### Requirement: exhaustive-window-list

mipbar SHALL display an indicator that opens a popover listing every open Hyprland
window. The list SHALL be derived from the compositor's complete client set, and
SHALL NOT be filtered through an enumerated list of workspace ids or names — so a
window on any workspace appears whether or not that workspace is one the bar draws.

#### Scenario: window on a workspace the bar does not draw

- **WHEN** a window is on a workspace outside the bar's workspace buttons (for
  example id 10, id 11, or a named workspace)
- **THEN** that window SHALL appear as a row in the picker

#### Scenario: window on a special workspace

- **WHEN** a window is on a special workspace (including `special:minimized`)
- **THEN** that window SHALL appear as a row in the picker

#### Scenario: every client is listed

- **WHEN** the picker is opened
- **THEN** the number of rows SHALL equal the number of clients Hyprland reports,
  with no window omitted for any reason

#### Scenario: no windows open

- **WHEN** no windows are open
- **THEN** the picker SHALL show an empty list and SHALL NOT error

### Requirement: flat-row-presentation

Rows SHALL be presented as a single flat list — not grouped, sectioned, or ordered by
workspace — and SHALL NOT carry status markers indicating whether a row's workspace is
reachable. Each row SHALL show the window's application icon and its title.

#### Scenario: row contents

- **WHEN** the picker lists a window
- **THEN** the row SHALL show that window's app icon and its title

#### Scenario: unresolvable app icon

- **WHEN** a window's class does not resolve to an icon in the GTK icon theme
- **THEN** the row SHALL show the `application-x-executable` fallback icon

#### Scenario: window without a title

- **WHEN** a window reports an empty title
- **THEN** the row SHALL fall back to the window's class, and to a generic label if
  the class is also empty

#### Scenario: no grouping or markers

- **WHEN** the picker contains windows from several different workspaces, including
  ones the bar does not draw
- **THEN** all rows SHALL appear in one flat list with no workspace headers, no
  separators between workspaces, and no per-row reachability indicator

### Requirement: go-to-window-on-primary-click

Left-clicking a row SHALL switch to that window's workspace and focus the window,
leaving the window where it is.

#### Scenario: window on another workspace

- **WHEN** the user left-clicks the row for a window on a workspace other than the
  current one
- **THEN** the compositor SHALL switch to that window's workspace and focus that
  window, and the window SHALL NOT change workspace

#### Scenario: window on the current workspace

- **WHEN** the user left-clicks the row for a window already on the current workspace
- **THEN** that window SHALL be focused

#### Scenario: minimized window degrades to bring-here

- **WHEN** the user left-clicks the row for a window on a special workspace, which has
  no workspace to navigate to
- **THEN** the window SHALL instead be moved to the current workspace and focused

### Requirement: bring-window-here-on-secondary-click

Right-clicking a row SHALL move that window to the current workspace and focus it,
regardless of where it was. This is the recovery path for a window whose workspace is
bound to a monitor that is not connected, where navigating to it would achieve
nothing.

#### Scenario: rescue a window from an unreachable workspace

- **WHEN** the user right-clicks the row for a window on a workspace bound to a
  disconnected monitor
- **THEN** that window SHALL be moved to the current workspace and focused

#### Scenario: bring a window from a normal workspace

- **WHEN** the user right-clicks the row for a window on another connected workspace
- **THEN** that window SHALL be moved to the current workspace and focused, and the
  view SHALL NOT switch away from the current workspace

#### Scenario: secondary click does not also trigger go-to

- **WHEN** the user right-clicks a row
- **THEN** only the bring-here action SHALL run; the left-click go-to action SHALL NOT
  also fire

### Requirement: live-list-updates

The picker's contents SHALL track window lifecycle and movement without polling and
without requiring the popover to be reopened.

#### Scenario: window opened

- **WHEN** a new window is opened
- **THEN** a row for it SHALL appear in the picker

#### Scenario: window closed

- **WHEN** a window is closed
- **THEN** its row SHALL be removed from the picker

#### Scenario: window moved between workspaces

- **WHEN** a window moves to a different workspace
- **THEN** the picker SHALL remain accurate, still listing the window exactly once
