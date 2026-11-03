# Proposal

Bean: [mipnix-7zn9](../../../.beans/mipnix-7zn9--mooie-hover-icoonknoppen-in-mipbar.md)

## Why

In mipbar only the chip icon (system monitor) feels like a button: it has padding and a rounded hover. The other icons (bell, displays, lock, minimized, all windows, coffee, camera, screen share) have little or no padding, and coffee, camera and screen share have no hover at all. Each new icon gets its own ad hoc styling, so the bar drifts further apart.

## What Changes

- Every icon in the bar becomes a button with the same padding, radius and hover as the chip icon, via one shared style.
- `.StatusIcon button { all: unset }` goes; padding moves from the outer box to the button, so it is inside the hover area.
- A new icon gets this presentation by using the shared class, without its own padding or hover rules. A test guards this.
- Keep-awake on is shown in the same red as camera and screen share (`#ff4444` dark, `#cc0000` light) instead of amber.
- The coffee glyph moves 1px down to correct how it looks.
- Camera and screen share get the same icon size.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `bar-visual-style`: a requirement that every icon in the bar is a uniform button, including icons added later.
- `keep-awake-toggle`: the on state uses the indicator red.

## Impact

- `packages/mipbar/style.scss`, `packages/mipbar/theme.ts`
- `packages/mipbar/widget/{Caffeine,Camera,Screenshare,Notifications,Displays,SshKey,Minimized,AllWindows,SystemMonitor}.tsx`: the shared class
- A new test in `packages/mipbar/widget/`
- Rollout: `rme up_home`
