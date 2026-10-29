## Why

The mipbar camera indicator is always visible, even with the camera off. WirePlumber keeps an Intel IPU6 capture device (`/dev/video16`) open, and the `lsof /dev/video*` check counts that as camera use. Ignoring WirePlumber in `lsof` is not enough: on IPU6/MIPI cameras every app reaches the camera through PipeWire and libcamera, so real camera use would then never show.

Related task: [mipnix-9n1n](../../../.beans/mipnix-9n1n--mipbar-camera-icon-red-while-camera-is-off.md)

## What Changes

- Detect camera use through PipeWire: a camera-backed `Video/Source` node (libcamera or v4l2) that has active links to client streams.
- Keep `lsof /dev/video*` as a second check for apps that open a UVC webcam directly, ignoring `pipewire` and `wireplumber`.
- Screencast sources no longer count as camera use.
- The tooltip lists every app using the camera instead of only the first.
- A click with one app focuses its window. With several apps, a click opens a menu that lists them, and choosing one focuses its window.
- The requirement that pins detection to polling `lsof` every 5 seconds is replaced.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `camera-indicator`: detection through PipeWire plus direct V4L2, no false positives from PipeWire's own device handles, all apps in the tooltip, and a menu to pick an app when several use the camera.

## Impact

- **Modified files**: `packages/mipbar/widget/Camera.tsx`, possibly `packages/mipbar/style.scss` for the menu.
- **Dependencies**: PipeWire state through `AstalWp` (already used in `QuickSettingsPanel.tsx`) or `pw-dump`, `lsof` as today.
- **Hosts**: every host running mipbar. Hosts with an IPU6 camera go from always-on to correct; hosts with a UVC webcam keep working.
