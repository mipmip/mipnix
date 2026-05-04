## Context

The bar already has `menubutton` + `popover` patterns (datetime/calendar). The system monitor follows the same UX: static icon in bar, popover with details on click.

Existing widgets use `createPoll` with shell commands for data — same approach here.

## Goals / Non-Goals

**Goals:**
- Show CPU, memory, network throughput, disk usage, local IP, external IP in a popover
- Poll each sensor at an appropriate interval
- Static monitor icon in the bar

**Non-Goals:**
- Graphs or historical data
- Alerts/notifications on thresholds
- Configurable sensors

## Decisions

### Use `createPoll` with shell commands for each sensor

Each sensor gets its own `createPoll` with a shell command and tailored interval:

| Sensor      | Command                          | Interval |
|-------------|----------------------------------|----------|
| CPU         | Parse `/proc/stat`               | 3s       |
| Memory      | `free -h`                        | 5s       |
| Network     | Parse `/proc/net/dev`            | 3s       |
| Disk        | `df -h /`                        | 60s      |
| Local IP    | `hostname -I`                    | 60s      |
| External IP | `curl -s ifconfig.me`            | 300s     |

**Why**: Consistent with existing codebase patterns (`createPoll` used for datetime). Different intervals avoid unnecessary work for slow-changing values.

### Use a `menubutton` with `popover` for the submenu

Same pattern as the datetime widget.

**Why**: Consistent UX across the bar. GTK handles popover positioning and dismissal.

### Popover layout as a vertical box with label rows

Each sensor is a horizontal box with an icon label and a value label, inside a vertical box.

```
┌───────────────────────────────┐
│ 󰍛  CPU           23%         │
│ 󰘚  Memory        4.2 / 16 GB │
│ 󰛳  Network       ↓12 ↑3 MB/s │
│ 󰋊  Disk          45 / 500 GB │
│ ─────────────────────────────│
│ 󰩟  Local IP      192.168.1.5 │
│ 󰩠  External IP   85.12.34.56 │
└───────────────────────────────┘
```

### Static bar icon: 󰍛

Use the nerd font CPU/monitor icon `󰍛`. Consistent with the AppLauncher pattern of using nerd font characters in labels.

## Risks / Trade-offs

[Risk] `curl -s ifconfig.me` requires network access and may be slow or fail → Mitigation: Long poll interval (5min), show "..." or "N/A" on failure.

[Risk] CPU usage requires reading `/proc/stat` twice with a delta — a single poll can't compute usage from one snapshot → Mitigation: Use a bash one-liner that reads twice with a brief sleep, or use `top -bn1` which does this internally.
