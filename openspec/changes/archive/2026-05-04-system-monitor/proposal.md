## Why

**Bean**: [mipbar-gmbw](../../../.beans/mipbar-gmbw--monitor-icon-with-submenu-with-common-sensors.md)

The bar lacks a quick way to glance at system health. A system monitor widget with a popover gives at-a-glance access to CPU, memory, network, disk, and IP information without opening a terminal.

## What Changes

- Add a new `SystemMonitor` widget with a static monitor icon in the bar's end section
- Clicking the icon opens a popover showing: CPU usage, memory usage, network throughput, disk usage, local IP, and external IP
- Each sensor polls at an appropriate interval (fast for CPU/memory/network, slow for disk/IP)

## Capabilities

### New Capabilities

- `system-monitor`: A bar widget with a popover displaying system sensor readings

### Modified Capabilities

None.

## Impact

- New file: `widget/SystemMonitor.tsx`
- `widget/Bar.tsx` — import and place `SystemMonitor` in the end section
- `style.scss` — styling for the monitor popover layout
