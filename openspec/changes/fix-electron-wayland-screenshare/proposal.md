## Why

Screen sharing in Slack fails with "Please check your system preferences to give screen
share access to Slack." On Wayland there is no OS-level screen-share permission toggle;
the message is Slack reporting a failed screen-capture attempt. The portal stack
(`xdg-desktop-portal-hyprland`, `-gtk`, PipeWire, WirePlumber) is already running and
exposes `org.freedesktop.portal.ScreenCast`. The actual cause is that the NixOS Slack
wrapper only enables its Wayland screen-capture flags when the environment variable
`NIXOS_OZONE_WL` is set, and that variable is currently unset — so Slack launches without
`--enable-features=...WebRTCPipeWireCapturer` and cannot capture the screen.

## What Changes

- Add `NIXOS_OZONE_WL = "1"` to `environment.sessionVariables` in the Hyprland desktop
  module, alongside the existing `ELECTRON_OZONE_PLATFORM_HINT = "wayland"`.
- This makes the NixOS Electron/Chromium wrappers (Slack and others) inject their Wayland
  flags — including `--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer`
  and `--ozone-platform-hint=auto` — enabling PipeWire-based screen capture through the
  existing desktop portal.
- No portal, PipeWire, or Slack package changes are needed; only the session variable.

## Capabilities

### New Capabilities

- `electron-wayland-screenshare`: Ensure Electron/Chromium applications on the Hyprland
  Wayland session run with the NixOS Wayland flags required for PipeWire screen capture,
  so screen sharing works through the desktop portal.

### Modified Capabilities

<!-- None: no existing spec's requirements change. -->

## Impact

- `modules/programs/desktop/de/hyprland.nix`: add one session variable
  (`NIXOS_OZONE_WL = "1"`) to the existing `environment.sessionVariables` block.
- Affects all Electron/Chromium apps in the Hyprland session (Slack, and others that use
  the NixOS `NIXOS_OZONE_WL`-gated wrappers), enabling Wayland-native rendering and
  screen capture.
- Requires a NixOS rebuild (`up_machine`) and a re-login, since `environment.sessionVariables`
  is evaluated at session start.
