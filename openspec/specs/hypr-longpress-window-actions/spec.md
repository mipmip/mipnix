# hypr-longpress-window-actions Specification

## Purpose
TBD - created by archiving change hypr-longpress-window-actions. Update Purpose after archive.
## Requirements
### Requirement: Long-press detection on pointer devices
The daemon SHALL detect a left mouse button hold of 2 seconds or more with less than 5 pixels of cursor movement from the initial press position. The daemon SHALL listen on all connected pointer-type evdev devices simultaneously.

#### Scenario: Successful long-press triggers menu
- **WHEN** the user presses and holds LMB for 2 seconds without moving the cursor more than 5px
- **THEN** the window action menu SHALL appear at the cursor position

#### Scenario: Movement cancels long-press
- **WHEN** the user presses LMB and moves the cursor more than 5px before 2 seconds elapse
- **THEN** the long-press timer SHALL be cancelled and no menu SHALL appear

#### Scenario: Early release cancels long-press
- **WHEN** the user presses and releases LMB before 2 seconds elapse
- **THEN** no menu SHALL appear and the click SHALL pass through normally

#### Scenario: Multiple pointer devices
- **WHEN** the daemon starts
- **THEN** it SHALL enumerate all evdev devices with pointer capabilities (EV_REL or EV_ABS with BTN_LEFT) and listen on all of them

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

### Requirement: Action dispatch to correct window
The daemon SHALL capture the active window address before spawning rofi and dispatch the selected action to that specific window by address via hyprctl.

#### Scenario: Close action
- **WHEN** the user selects "Close" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch closewindow address:<addr>` targeting the captured window

#### Scenario: Fullscreen action
- **WHEN** the user selects "Fullscreen" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch fullscreen 1` on the captured window

#### Scenario: Float action
- **WHEN** the user selects "Float" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch togglefloating` on the captured window

#### Scenario: Minimize action
- **WHEN** the user selects "Minimize" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch movetoworkspacesilent special:minimized` on the captured window

#### Scenario: Pin action
- **WHEN** the user selects "Pin" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch pin` on the captured window

#### Scenario: Move to workspace action
- **WHEN** the user selects "Move to Workspace N" from the menu
- **THEN** the daemon SHALL execute `hyprctl dispatch movetoworkspace N,address:<addr>` for the captured window

### Requirement: Nix packaging and autostart
The daemon SHALL be packaged as a nix derivation with python3, python-evdev, and rofi as dependencies, and SHALL be autostarted with Hyprland.

#### Scenario: Daemon starts with Hyprland
- **WHEN** Hyprland starts
- **THEN** the daemon SHALL be launched via exec-once in autostart.conf

#### Scenario: Daemon logs permission errors
- **WHEN** the daemon cannot open any evdev device due to insufficient permissions
- **THEN** it SHALL log a clear error message indicating the user needs to be in the input group

