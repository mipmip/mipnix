# Screenshare Indicator

### Requirement: screenshare-hidden-by-default

The screenshare indicator SHALL NOT be visible when no screenshare session is active.

#### Scenario: no active screenshare

WHEN no screenshare session is active
THEN the screenshare indicator SHALL be hidden

### Requirement: screenshare-visible-when-active

The screenshare indicator SHALL be visible when a screenshare session is active.

#### Scenario: screenshare starts

WHEN a screenshare session becomes active (Hyprland screencast event with state on)
THEN the screenshare indicator SHALL become visible

#### Scenario: screenshare ends

WHEN the screenshare session ends (Hyprland screencast event with state off)
THEN the screenshare indicator SHALL become hidden

### Requirement: screenshare-icon

The screenshare indicator SHALL display a distinct icon that clearly communicates screen sharing is active. The icon SHALL be `video-display-symbolic` — not a camera icon.

#### Scenario: indicator appearance

WHEN screenshare is active
THEN the indicator SHALL display `video-display-symbolic`

### Requirement: screenshare-process-tooltip
The screenshare indicator SHALL display a tooltip on hover showing the name of the application that is sharing the screen.

#### Scenario: hover shows process name
- **WHEN** a screenshare is active and the user hovers over the screenshare indicator
- **THEN** the tooltip SHALL display the name of the sharing application (e.g., "Firefox", "OBS")

#### Scenario: process name unavailable
- **WHEN** a screenshare is active but the sharing process cannot be identified
- **THEN** the tooltip SHALL display "Screen sharing active"

### Requirement: screenshare-click-to-focus
The screenshare indicator SHALL focus the sharing application's window when clicked.

#### Scenario: click focuses sharing window
- **WHEN** the user clicks the screenshare indicator while a screenshare is active
- **THEN** Hyprland SHALL focus the window belonging to the sharing process

#### Scenario: click when process unknown
- **WHEN** the user clicks the screenshare indicator but the sharing process PID is unknown
- **THEN** the click SHALL have no effect (no error, no crash)

### Requirement: screenshare-process-query
The system SHALL query the xdg-desktop-portal D-Bus sessions to identify the screensharing process when a screencast event is detected.

#### Scenario: portal identifies sharing process
- **WHEN** a Hyprland screencast event fires with state ON
- **THEN** the system SHALL query xdg-desktop-portal sessions via D-Bus and resolve the requesting process name and PID

#### Scenario: process query fails gracefully
- **WHEN** the portal query fails or returns no matching sessions
- **THEN** the system SHALL fall back to showing the generic indicator without process information
