# Electron Wayland Screen Share

## ADDED Requirements

### Requirement: ozone-wayland-flag-enabled

The Hyprland graphical session SHALL set the `NIXOS_OZONE_WL` environment variable so that NixOS-wrapped Electron/Chromium applications inject their Wayland flags, including the PipeWire screen capturer.

#### Scenario: session variable present at login

- **WHEN** a user logs into the Hyprland session
- **THEN** `NIXOS_OZONE_WL` SHALL be set in the session environment alongside `ELECTRON_OZONE_PLATFORM_HINT=wayland`

#### Scenario: Electron app launches with Wayland flags

- **WHEN** a NixOS-wrapped Electron application (e.g. Slack) is launched in the session
- **THEN** it SHALL run with the wrapper's Wayland flags, including `--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer`

### Requirement: slack-screen-share-works

Screen sharing from Slack SHALL succeed using the desktop screen-cast portal, without surfacing the "give screen share access" message.

#### Scenario: starting a screen share

- **WHEN** the user starts a screen share in Slack
- **THEN** the Hyprland screen/window picker (via `org.freedesktop.portal.ScreenCast`) SHALL appear and the selected source SHALL be shared

#### Scenario: portal stack already available

- **WHEN** `xdg-desktop-portal-hyprland`, PipeWire, and WirePlumber are running and `org.freedesktop.portal.ScreenCast` is exposed
- **THEN** enabling `NIXOS_OZONE_WL` SHALL be sufficient for Slack screen share to work, with no portal or package changes required
