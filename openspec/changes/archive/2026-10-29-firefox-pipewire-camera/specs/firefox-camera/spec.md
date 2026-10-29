## Purpose

Make Firefox on every one of Pim's computers reach cameras the same way, through PipeWire, so cameras that only work through libcamera are usable in the browser.

## ADDED Requirements

### Requirement: firefox-camera-through-pipewire
Firefox SHALL access cameras through PipeWire instead of opening video devices directly, on every computer that uses the `pim-firefox` module.

#### Scenario: IPU6 camera in a video call
- **WHEN** a web page in Firefox asks for the camera on a laptop with an Intel IPU6 camera
- **THEN** the camera list SHALL show one entry for the camera and the page SHALL receive a live image

#### Scenario: USB webcam in a video call
- **WHEN** a web page in Firefox asks for the camera on a computer with a USB webcam
- **THEN** the page SHALL receive a live image from that webcam

#### Scenario: no direct device access
- **WHEN** Firefox uses a camera
- **THEN** no Firefox process SHALL hold a `/dev/video*` device open

### Requirement: firefox-camera-released
Firefox SHALL stop using the camera when no page uses it anymore.

#### Scenario: tab closed
- **WHEN** the user closes the last tab that uses the camera
- **THEN** Firefox SHALL release the camera within a few seconds
