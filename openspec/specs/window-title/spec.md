# Window Title

### Requirement: show-focused-title

The bar SHALL display the title of the currently focused window in the center section.

#### Scenario: window is focused

WHEN a window is focused
THEN the center section SHALL display that window's title

#### Scenario: focus changes

WHEN the user switches to a different window
THEN the center section SHALL update to show the new window's title

#### Scenario: title changes

WHEN the focused window updates its title (e.g., browser tab switch)
THEN the displayed title SHALL update reactively

### Requirement: show-app-icon

The window title SHALL be preceded by the focused application's icon.

#### Scenario: icon display

WHEN a window is focused
THEN the center section SHALL show the app icon followed by the title

### Requirement: truncate-long-titles

Long window titles SHALL be truncated with ellipsis.

#### Scenario: long title

WHEN the window title exceeds the available space
THEN the title SHALL be truncated with an ellipsis

### Requirement: hide-when-no-focus

The window title widget SHALL be hidden when no window is focused.

#### Scenario: no focused window

WHEN no window is focused (e.g., empty desktop)
THEN the center section SHALL be empty
