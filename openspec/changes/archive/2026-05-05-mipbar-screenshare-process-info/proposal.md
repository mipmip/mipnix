## Why

The screenshare indicator currently shows a generic camera icon with no information about what is sharing the screen. When multiple apps could be sharing (browser, video call, OBS), the user has no way to identify the source or quickly navigate to it.

Related task: [mipnix-o7t0](../../.beans/mipnix-o7t0--mipbar-show-which-process-is-using-screensharing.md)

## What Changes

- On screenshare start, query PipeWire to identify the process that initiated the screenshare
- Show the process name in a tooltip when hovering over the screenshare indicator
- Click the screenshare indicator to focus the sharing application's window via Hyprland

## Capabilities

### New Capabilities
<!-- None — this modifies an existing capability -->

### Modified Capabilities
- `screenshare-indicator`: Adding process identification (tooltip with app name) and click-to-focus behavior

## Impact

- **Files modified**: `packages/mipbar/widget/Screenshare.tsx`
- **Dependencies**: Requires `pw-dump` (PipeWire CLI) available at runtime for process identification
- **No new packages**: PipeWire tools are already present on the system
