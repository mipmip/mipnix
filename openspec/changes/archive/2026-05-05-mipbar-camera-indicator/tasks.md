## 1. Camera Component

- [x] 1.1 Create `Camera.tsx` with `pw-dump --monitor` subprocess that detects `Stream/Input/Video` nodes linked to camera sources
- [x] 1.2 Extract process name and PID from the video stream, normalize NixOS-wrapped binary names
- [x] 1.3 Show/hide indicator based on camera stream presence
- [x] 1.4 Add tooltip showing process name (or "Camera in use" as fallback)
- [x] 1.5 Add click handler to focus the camera-using window via `hyprctl dispatch focuswindow pid:<pid>`

## 2. Screenshare Icon Fix

- [x] 2.1 Change screenshare icon in `Screenshare.tsx` from `camera-web-symbolic` to `video-display-symbolic`

## 3. Bar Integration

- [x] 3.1 Import and add `<Camera />` component in `Bar.tsx` next to `<Screenshare />`

## 4. Verification

- [x] 4.1 Verify mipbar builds successfully
- [x] 4.2 Test camera indicator with a real camera app
