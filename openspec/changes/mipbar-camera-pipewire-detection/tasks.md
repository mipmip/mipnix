## 1. Detection

- [x] 1.1 Replace the `lsof` poll in `Camera.tsx` with one that returns every PID holding `/dev/video*` except `pipewire` and `wireplumber`; verify that with the camera off the command prints nothing on the IPU6 laptop
- [x] 1.2 Add PipeWire detection by parsing `pw-dump` in `cameraUsers.ts` (camera sources only: `device.api` is `libcamera` or `v4l2`), refreshed on AstalWp video signals; verify with unit tests on a real capture and by running the parser on full live dumps with Snapshot on and off
- [x] 1.3 Resolve camera users through links from a camera source to a running node and its client's `application.process.id`; verify the unit tests for screencast, several users and missing client data pass in `checks.mipbar-camera`
- [x] 1.4 Merge both detectors into one list of `{ pid, name }` deduplicated by PID; verify the indicator shows while Snapshot uses the camera and hides within 1.5 seconds after it closes

## 2. Tooltip and click

- [x] 2.1 Show every app name in the tooltip, and "Camera in use" when none is identified; verify with the `tooltipText` unit tests
- [x] 2.2 Make a click focus the window when one app uses the camera; verify `hyprctl dispatch focuswindow pid:<pid>` moves focus from workspace 8 to Snapshot on workspace 9
- [ ] 2.3 Add a popover menu for two or more apps that focuses the chosen app and closes; verify with two apps on the camera at once
- [ ] 2.4 Style the menu in `style.scss` like the `AllWindows` popover; verify it looks the same in light and dark mode

## 3. Integration

- [x] 3.1 Build mipbar with `nix build .#mipbar` and verify it succeeds
- [x] 3.2 Verify on the IPU6 laptop: indicator hidden with the camera off, visible while Snapshot uses it, hidden again after it closes
- [ ] 3.3 Verify on a host with a UVC webcam that direct V4L2 use (`ffplay /dev/video0`) shows the indicator
- [x] 3.4 Add the missing `# camera-indicator`, `## Purpose` and `## Requirements` headers to `openspec/specs/camera-indicator/spec.md` without changing its requirements; verify `openspec validate mipbar-camera-pipewire-detection --strict` passes with no "Archive would refuse" notice

## Workflow follow-up

- Archive the change and add the `openspec-link` to bean `mipnix-9n1n`.
- Set bean `mipnix-9n1n` to `completed`.
