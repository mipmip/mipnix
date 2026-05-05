## ADDED Requirements

### Requirement: camera-hidden-by-default
The camera indicator SHALL NOT be visible when no camera is in use.

#### Scenario: no active camera
- **WHEN** no application is using a camera
- **THEN** the camera indicator SHALL be hidden

### Requirement: camera-visible-when-active
The camera indicator SHALL be visible when a camera is in use.

#### Scenario: camera starts
- **WHEN** an application opens a camera via PipeWire
- **THEN** the camera indicator SHALL become visible

#### Scenario: camera stops
- **WHEN** the application releases the camera
- **THEN** the camera indicator SHALL become hidden

### Requirement: camera-icon
The camera indicator SHALL display the `camera-web-symbolic` icon.

#### Scenario: indicator appearance
- **WHEN** a camera is in use
- **THEN** the indicator SHALL display the `camera-web-symbolic` icon

### Requirement: camera-process-tooltip
The camera indicator SHALL display a tooltip showing the name of the application using the camera.

#### Scenario: hover shows process name
- **WHEN** a camera is in use and the user hovers over the camera indicator
- **THEN** the tooltip SHALL display the name of the application (e.g., "firefox", "obs")

#### Scenario: process name unavailable
- **WHEN** a camera is in use but the process cannot be identified
- **THEN** the tooltip SHALL display "Camera in use"

### Requirement: camera-click-to-focus
The camera indicator SHALL focus the camera-using application's window when clicked.

#### Scenario: click focuses camera app window
- **WHEN** the user clicks the camera indicator while a camera is in use
- **THEN** Hyprland SHALL focus the window belonging to the camera-using process

#### Scenario: click when process unknown
- **WHEN** the user clicks the camera indicator but the process PID is unknown
- **THEN** the click SHALL have no effect

### Requirement: camera-event-based-detection
The system SHALL use `pw-dump --monitor` as an event-based subprocess to detect camera usage changes without polling.

#### Scenario: camera detected via PipeWire event
- **WHEN** PipeWire state changes and a new video stream connected to a camera source appears
- **THEN** the system SHALL detect the camera usage and update the indicator

#### Scenario: detection subprocess fails gracefully
- **WHEN** `pw-dump --monitor` is unavailable or crashes
- **THEN** the camera indicator SHALL remain hidden without errors
