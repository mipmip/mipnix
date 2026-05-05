## Why

There is no indication in mipbar when the camera is in use. Users have no way to know if an app has the webcam open, which process is using it, or to quickly navigate to that process. Additionally, the screenshare indicator currently uses `camera-web-symbolic` which is a webcam icon — misleading since it indicates screen sharing, not camera usage.

Related task: [mipnix-h24f](../../.beans/mipnix-h24f--mipbar-show-camera-on-and-show-who-is-using-camera.md)

## What Changes

- Add a new camera indicator that shows when a webcam is in use, with tooltip showing the process name and click-to-focus
- Use `pw-dump --monitor` as an event-based subprocess to detect camera stream changes (zero CPU when idle)
- Change the screenshare indicator icon from `camera-web-symbolic` to a screen-appropriate icon (e.g., `screen-shared-symbolic` or `display-symbolic`)
- Use `camera-web-symbolic` for the new camera indicator (where it actually belongs)

## Capabilities

### New Capabilities
- `camera-indicator`: Camera usage indicator — visibility, process identification, tooltip, click-to-focus, event-based detection via PipeWire

### Modified Capabilities
- `screenshare-indicator`: Changing icon from `camera-web-symbolic` to a screen-specific icon

## Impact

- **New files**: `packages/mipbar/widget/Camera.tsx`
- **Modified files**: `packages/mipbar/widget/Screenshare.tsx` (icon change), `packages/mipbar/widget/Bar.tsx` (add Camera component)
- **Dependencies**: `pw-dump` (PipeWire CLI, already available on the system)
