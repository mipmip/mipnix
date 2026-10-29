## Context

See proposal.md for why. `Camera.tsx` polls `lsof /dev/video*` every 5 seconds and shows the first PID it finds. The 2026-05-05 camera change designed detection with `pw-dump --monitor`, but the code shipped with `lsof` polling and nothing records why.

On the IPU6 laptop the camera (ov01a10 sensor) is only usable through libcamera inside PipeWire. PipeWire exposes it as one `Video/Source` node, `libcamera_input.*`, in state `suspended` while idle. WirePlumber keeps `/dev/video16` open all the time.

mipbar already uses `AstalWp` (WirePlumber bindings) in `QuickSettingsPanel.tsx`. Its `Video` object exposes `sources` and `streams`. A `Node` has `state`, `serial` and `get_pw_property()`, and a `Stream` has `target_serial`.

## Goals / Non-Goals

**Goals:**
- One list of camera users, built from two detectors, that drives visibility, tooltip and click.
- React to PipeWire changes without waiting for a poll.

**Non-Goals:**
- Showing which camera device is in use when there are several.
- Detecting camera use by processes of other users. `lsof` as the desktop user cannot see them, and that stays so.
- Changing the screenshare indicator.

## Decisions

### 1. PipeWire detection through `pw-dump`, triggered by AstalWp

**Decision**: Read state with one `pw-dump` call and parse it in a pure helper (`cameraUsers.ts`). A source counts as a camera when its `media.class` is `Video/Source` and its `device.api` is `libcamera` or `v4l2`. A camera user is a node in state `running` that a link connects to a camera source. Its PID and name come from the node's client object (`application.process.id`, `application.process.binary`). Refresh on AstalWp's `recorder-added/removed` and `source-added/removed` signals, again one second later, and every 5 seconds.

**Why not AstalWp alone**: a probe during implementation showed that AstalWp reports `state` 0 for video nodes in every situation, `target_serial` 0, and no PID, because the PID lives on the PipeWire client object, not on the stream node. Its signals are still reliable as a trigger.

**Alternatives considered**:
- *`pw-dump --monitor` subprocess*: event-based too, but needs JSON buffering of large partial updates.
- *Polling `pw-dump` only*: brings back the 5 second delay when a camera stops.

### 2. Keep `lsof` for direct V4L2 access

**Decision**: Keep a poll of `lsof -Fpc /dev/video*` for apps that open a UVC webcam directly, and drop every entry whose command is `pipewire` or `wireplumber`. Return all remaining PIDs, not only the first.

**Rationale**: Without a hook from the kernel there is no event for direct V4L2 opens. A 5 second poll is acceptable here, because direct V4L2 use is rare now.

### 3. Merge both detectors by PID

**Decision**: Combine both lists into one list of `{ pid, name }`, deduplicated by PID. Name comes from `application.name` when PipeWire gives one, otherwise from `/proc/<pid>/cmdline` with the existing `-wrapped` normalization. A camera source in state `running` without any matching stream still counts as in use, with no identified app, so the tooltip falls back to "Camera in use".

### 4. Menu for several apps

**Decision**: Use a `menubutton` with a `popover`, following `AllWindows.tsx`. With one app, the click focuses it through `hyprctl dispatch focuswindow pid:<pid>` and the popover does not open. With two or more, the popover lists the apps; choosing one focuses it and closes the popover.

## Risks / Trade-offs

- **[`pw-dump` cost]** One dump is about 400 KB of JSON. → Runs every 5 seconds and on signals only, and the parse is a single pass.
- **[Hidden apps]** Some apps (Snapshot) only open the camera while their window is visible. → Correct behavior: the indicator follows real camera use.
- **[Screencast sources]** xdg-desktop-portal-hyprland also creates `Video/Source` nodes. → They have no `device.api` of `libcamera` or `v4l2`, so decision 1 excludes them. Verify with OBS screen capture during testing.
- **[Flatpak or sandboxed apps]** `application.process.id` may be a PID in another namespace, so focus fails. → The name still shows; the click does nothing for that app.
- **[Two code paths]** More code than the single `lsof` call. → Both feed one list, so the UI has one input.

## Migration Plan

Rebuild and switch home-manager on the IPU6 laptop and on a host with a UVC webcam. Rollback is reverting the commit.
