## Why

When connecting an external monitor, mipbar doesn't appear on it — it only shows on the laptop display where it was created at startup. When monitors change, stale bar windows can be left behind. The bar should always appear on the preferred monitor (external if available, laptop otherwise) and react dynamically to monitor hotplug events.

## What Changes

- Show exactly one bar on the preferred monitor: external (non-eDP) if connected, laptop (eDP) if not
- Listen for GTK4 `monitor-added` and `monitor-removed` signals on `Gdk.Display`
- On monitor change: destroy the current bar and recreate it on the new preferred monitor
- Assign unique window names per monitor to prevent conflicts

## Capabilities

### New Capabilities
- `bar-monitor-selection`: Dynamic monitor selection for the bar — preferred monitor logic, hotplug handling, single bar lifecycle

### Modified Capabilities
<!-- No existing spec-level requirements change -->

## Impact

- **Files modified**: `packages/mipbar/app.ts` (monitor lifecycle management), `packages/mipbar/widget/Bar.tsx` (unique window names)
- **No new dependencies**
