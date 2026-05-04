## 1. Create SystemMonitor Widget

- [x] 1.1 Create `widget/SystemMonitor.tsx` with a `menubutton` containing a 󰍛 icon label
- [x] 1.2 Add `createPoll` for CPU usage (3s interval)
- [x] 1.3 Add `createPoll` for memory usage (5s interval)
- [x] 1.4 Add `createPoll` for network throughput (3s interval)
- [x] 1.5 Add `createPoll` for disk usage (60s interval)
- [x] 1.6 Add `createPoll` for local IP (30s interval)
- [x] 1.7 Add `createPoll` for external IP (300s interval, with N/A fallback)
- [x] 1.8 Build popover layout with icon + value rows for each sensor

## 2. Integrate into Bar

- [x] 2.1 Import and add `<SystemMonitor />` to the end section of `widget/Bar.tsx`

## 3. Style

- [x] 3.1 Add popover styling for the monitor layout in `style.scss`

## 4. Verify

- [x] 4.1 Run `ags run .` and confirm the monitor icon appears in the bar
- [x] 4.2 Click the icon and confirm all sensor readings display
- [x] 4.3 Confirm values update at their expected intervals
