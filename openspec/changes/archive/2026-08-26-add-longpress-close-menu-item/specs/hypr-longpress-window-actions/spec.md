# hypr-longpress-window-actions Specification

## MODIFIED Requirements

### Requirement: Window action menu via rofi
The daemon SHALL spawn rofi in dmenu mode at the cursor position displaying the following actions: Close, Fullscreen, Float, Minimize, Pin, Move to Workspace 1-10, and Close menu (a no-op entry that dismisses the menu).

#### Scenario: Menu appears at cursor position
- **WHEN** the long-press triggers
- **THEN** rofi SHALL appear positioned near the cursor's screen-relative coordinates

#### Scenario: Menu lists all window actions
- **WHEN** the menu appears
- **THEN** it SHALL display: Close, Fullscreen, Float, Minimize, Pin, Move to Workspace entries for workspaces 1 through 10, and a "Close menu" entry

#### Scenario: Menu dismissed without selection
- **WHEN** the user presses Escape or clicks outside the menu
- **THEN** the menu SHALL close and no action SHALL be dispatched

#### Scenario: Close menu entry dismisses without acting
- **WHEN** the user selects the "Close menu" entry
- **THEN** the menu SHALL close and no action SHALL be dispatched to the window (it is a mouse-clickable equivalent of Escape / clicking outside)
