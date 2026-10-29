## MODIFIED Requirements

### Requirement: camera-hidden-by-default
The camera indicator SHALL NOT be visible when no camera is in use.

#### Scenario: no active camera
- **WHEN** no application is using a camera
- **THEN** the camera indicator SHALL be hidden

#### Scenario: media server holds a device open while idle
- **WHEN** PipeWire or WirePlumber keeps a video device open and no application is using a camera
- **THEN** the camera indicator SHALL be hidden

### Requirement: camera-visible-when-active
The camera indicator SHALL be visible when a camera is in use, whether the application opens the video device directly or reaches the camera through PipeWire.

#### Scenario: camera starts
- **WHEN** an application other than PipeWire or WirePlumber opens a video device
- **THEN** the camera indicator SHALL become visible

#### Scenario: camera starts through PipeWire
- **WHEN** an application starts receiving video from a camera source in PipeWire
- **THEN** the camera indicator SHALL become visible

#### Scenario: camera stops
- **WHEN** the last application stops using the camera
- **THEN** the camera indicator SHALL become hidden

### Requirement: camera-process-tooltip
The camera indicator SHALL display a tooltip listing the name of every application using the camera.

#### Scenario: hover shows process name
- **WHEN** one application is using the camera and the user hovers over the camera indicator
- **THEN** the tooltip SHALL display the name of the application (e.g., "firefox", "obs")

#### Scenario: hover shows all process names
- **WHEN** several applications are using the camera and the user hovers over the camera indicator
- **THEN** the tooltip SHALL list the name of each of these applications

#### Scenario: process name unavailable
- **WHEN** a camera is in use but no application can be identified
- **THEN** the tooltip SHALL display "Camera in use"

### Requirement: camera-click-to-focus
The camera indicator SHALL focus the window of the camera-using application when clicked, and SHALL let the user pick the application when several use the camera.

#### Scenario: click focuses camera app window
- **WHEN** the user clicks the camera indicator while exactly one identified application is using the camera
- **THEN** Hyprland SHALL focus the window belonging to that application

#### Scenario: click opens menu with several apps
- **WHEN** the user clicks the camera indicator while several identified applications are using the camera
- **THEN** a menu SHALL open that lists each of these applications

#### Scenario: choosing an app from the menu
- **WHEN** the user chooses an application in the camera menu
- **THEN** Hyprland SHALL focus the window belonging to that application and the menu SHALL close

#### Scenario: click when process unknown
- **WHEN** the user clicks the camera indicator but no application using the camera can be identified
- **THEN** the click SHALL have no effect

## ADDED Requirements

### Requirement: camera-ignores-screencast
The camera indicator SHALL only count video sources backed by a camera. Screen capture and other non-camera video sources SHALL NOT make the camera indicator visible.

#### Scenario: screenshare without camera
- **WHEN** an application records or shares the screen and no application uses a camera
- **THEN** the camera indicator SHALL be hidden

#### Scenario: screenshare and camera together
- **WHEN** an application shares the screen and another application uses the camera
- **THEN** the camera indicator SHALL be visible and SHALL list only the camera-using application

## REMOVED Requirements

### Requirement: camera-polling-detection
**Reason**: Polling `lsof /dev/video*` counts PipeWire's own device handles as camera use and cannot see applications that reach the camera through PipeWire.
**Migration**: Detection is covered by `camera-visible-when-active`, `camera-hidden-by-default` and `camera-ignores-screencast`, which describe the behavior without fixing the mechanism.
