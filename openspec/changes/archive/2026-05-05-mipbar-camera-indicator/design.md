## Context

Mipbar uses AGS (GTK 4) with reactive state via `createState`. The existing screenshare indicator listens for Hyprland `screencast` events and queries D-Bus portal sessions for process info. There is no equivalent Hyprland event for camera usage, so a different detection mechanism is needed.

PipeWire manages all video device access. When an app opens a camera, PipeWire creates a `Stream/Input/Video` node with `application.name` and `application.process.id`. The `pw-dump --monitor` command streams JSON arrays whenever PipeWire state changes — this provides event-based detection with zero CPU usage when idle.

AGS provides `subprocess` from `ags/process` for long-running subprocesses with stdout callbacks, already used in `app.ts` for gsettings monitoring.

## Goals / Non-Goals

**Goals:**
- Show a camera icon when any webcam is in use
- Tooltip with the process name using the camera
- Click to focus the camera-using application
- Event-based detection via `pw-dump --monitor` (no polling)
- Fix the screenshare icon to use a screen icon instead of a camera icon

**Non-Goals:**
- Showing which specific camera device is in use (laptop vs external)
- Multiple simultaneous camera users (show first match)
- Combining camera and screenshare into a single component (keep separate for clarity)

## Decisions

### 1. Use `pw-dump --monitor` subprocess for camera detection

**Decision**: Spawn `pw-dump --monitor` as a long-running subprocess. Parse each JSON update for `Stream/Input/Video` nodes linked to a video source (camera). Extract `application.name` and `application.process.id`.

**Alternatives considered**:
- *Polling with `fuser /dev/video*`*: Simple but wastes CPU and has detection delay.
- *`inotifywait` on `/dev/video*`*: Event-based but doesn't give process info directly.

**Approach**: Use `subprocess` from `ags/process`. On each stdout line (JSON array), filter for nodes where `media.class` is `Stream/Input/Video` and the stream is linked to a camera source (not a screencast portal). If found, set camera active with process info. If not found, set camera inactive.

### 2. Distinguish camera streams from screencast streams

**Decision**: Camera streams connect to V4L2 video source nodes. Screencast streams connect to xdg-desktop-portal nodes. Filter by checking `node.name` of the linked source — camera sources have `v4l2_input` in their node name.

**Alternative approach**: Simply check if any `Stream/Input/Video` node exists where `application.name` is not `xdg-desktop-portal`. This is simpler and covers the common case.

### 3. Screenshare icon change

**Decision**: Change the screenshare indicator icon from `camera-web-symbolic` to `screen-shared-symbolic`. If that icon isn't available in the theme, fall back to `computer-symbolic` or `display-symbolic`.

### 4. Camera indicator as a separate component

**Decision**: Create `Camera.tsx` as a new component, placed next to `Screenshare` in `Bar.tsx`.

**Rationale**: Keeps components focused and independent. Camera and screenshare have different detection mechanisms.

## Risks / Trade-offs

- **[pw-dump --monitor parsing]** The monitor output may emit partial JSON or large dumps. → Mitigation: Buffer lines and parse complete JSON arrays. Catch parse errors gracefully.
- **[Process name normalization]** Same NixOS `-wrapped` issue as screenshare. → Mitigation: Reuse the same basename + strip logic.
- **[Icon availability]** `screen-shared-symbolic` may not exist in all icon themes. → Mitigation: Check availability and fall back to `display-symbolic`.
