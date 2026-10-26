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

### Requirement: portal-can-authorize-screencast

The desktop portal SHALL be able to authorize ScreenCast session requests from
Electron/Chromium apps. The portal identifies the caller by opening
`/proc/<caller-pid>/root`; this SHALL succeed rather than failing with
`AccessDenied: Portal operation not allowed: Unable to open /proc/<pid>/root`.

To achieve this the session SHALL use the reference dbus-daemon
(`services.dbus.implementation = "dbus"`) rather than dbus-broker, and SHALL set
`kernel.yama.ptrace_scope = 0`.

#### Scenario: portal reads the caller's process root

- **WHEN** a Wayland Electron app (e.g. Slack) requests an `org.freedesktop.portal.ScreenCast` session
- **THEN** the portal SHALL be able to open the caller's `/proc/<pid>/root` and authorize the request, rather than failing with `AccessDenied: Portal operation not allowed: Unable to open /proc/<pid>/root`

#### Scenario: reference dbus-daemon in use

- **WHEN** the system boots
- **THEN** `services.dbus.implementation` SHALL be `"dbus"` (reference dbus-daemon), because the portal's caller verification for ScreenCast fails under dbus-broker

#### Scenario: ptrace_scope permits same-user portal verification

- **WHEN** the system boots
- **THEN** `kernel.yama.ptrace_scope` SHALL be `0`, so the portal can read the calling app's `/proc/<pid>/root` for authorization

### Requirement: slack-screen-share-works

Screen sharing from Slack SHALL succeed using the desktop screen-cast portal, without surfacing the "give screen share access" message.

#### Scenario: starting a screen share

- **WHEN** the user starts a screen share in Slack
- **THEN** the Hyprland screen/window picker (via `org.freedesktop.portal.ScreenCast`) SHALL appear and the selected source SHALL be shared

#### Scenario: both the Wayland flag and portal authorization are required

- **WHEN** `xdg-desktop-portal-hyprland`, PipeWire, and WirePlumber are running and `org.freedesktop.portal.ScreenCast` is exposed
- **THEN** Slack screen share SHALL work once `NIXOS_OZONE_WL` is set (so the capturer flag is injected) AND the portal can authorize the session (reference dbus-daemon + `ptrace_scope = 0`); `NIXOS_OZONE_WL` alone is NOT sufficient
