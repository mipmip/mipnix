## Context

Mipbar's `Screenshare.tsx` listens for Hyprland `screencast` events (`state,owner`). The `owner` field is just the capture type (0=monitor, 1=window), not the process name. To identify the sharing process, we need to query PipeWire.

When a screenshare is active, PipeWire creates a video stream node with properties including `application.name` and `application.process.id`. These can be retrieved via `pw-dump`.

Mipbar uses AGS (GTK 4) and already has `tooltipText` usage in other widgets (Tray, Workspaces).

## Goals / Non-Goals

**Goals:**
- Show the sharing application name on hover (tooltip)
- Click the indicator to focus the sharing application's window
- Graceful fallback if PipeWire query fails (show generic tooltip)

**Non-Goals:**
- Identifying the specific browser tab (future: mipnix-ge9i)
- Stopping the screenshare from the indicator
- Multiple simultaneous screenshare tracking

## Decisions

### 1. Query PipeWire via pw-dump on screencast event

**Decision**: When the Hyprland screencast event fires with state=1, spawn `pw-dump` and parse the JSON output to find video stream nodes associated with the screencast.

**Alternatives considered**:
- *PipeWire D-Bus API*: More complex, requires GDBus introspection, not well documented for this use case.
- *Parse /proc directly*: Would need to know the PID upfront, which we don't have from Hyprland alone.

**Approach**: Run `pw-dump` via `GLib.spawn_command_line_async` or AGS's exec utilities. Filter for nodes where `media.class` contains "Video" and `node.name` contains "screencast" or similar portal identifiers. Extract `application.name` and `application.process.id`.

### 2. Focus window via hyprctl

**Decision**: On click, run `hyprctl dispatch focuswindow pid:<pid>` to focus the sharing application.

**Rationale**: Hyprland's `focuswindow` dispatch with PID selector is the most reliable way to find and focus the correct window regardless of workspace.

### 3. Fallback behavior

**Decision**: If pw-dump fails or returns no matching streams, show "Screen sharing active" as the tooltip and disable click-to-focus.

## Risks / Trade-offs

- **[Timing]** PipeWire stream may not be immediately available when the Hyprland event fires. → Mitigation: Add a small delay (e.g., 500ms) before querying, or retry once.
- **[pw-dump overhead]** Spawning a subprocess on each screencast event. → Acceptable: events are rare (start/stop of screenshare).
- **[Multiple streams]** If multiple apps share simultaneously, pw-dump returns multiple matches. → Use the most recent stream or show all names in tooltip. Edge case for now.
