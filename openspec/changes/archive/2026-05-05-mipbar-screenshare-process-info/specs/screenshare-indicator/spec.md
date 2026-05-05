## ADDED Requirements

### Requirement: screenshare-process-tooltip
The screenshare indicator SHALL display a tooltip on hover showing the name of the application that is sharing the screen.

#### Scenario: hover shows process name
- **WHEN** a screenshare is active and the user hovers over the screenshare indicator
- **THEN** the tooltip SHALL display the name of the sharing application (e.g., "Firefox", "OBS Studio")

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

### Requirement: screenshare-pipewire-query
The system SHALL query PipeWire to identify the screensharing process when a screencast event is detected.

#### Scenario: PipeWire identifies sharing process
- **WHEN** a Hyprland screencast event fires with state ON
- **THEN** the system SHALL query PipeWire for active video streams and extract the application name and process ID

#### Scenario: PipeWire query fails gracefully
- **WHEN** PipeWire is unavailable or returns no matching streams
- **THEN** the system SHALL fall back to showing the generic indicator without process information
