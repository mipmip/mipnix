## 1. PipeWire Query

- [x] 1.1 Add a function to `Screenshare.tsx` that runs `pw-dump` and parses the JSON to find the screensharing process name and PID
- [x] 1.2 Call this function when the Hyprland screencast event fires with state ON (with a small delay for stream setup)
- [x] 1.3 Store the process name and PID in component state

## 2. Tooltip

- [x] 2.1 Add `tooltipText` to the screenshare indicator box showing the process name (or "Screen sharing active" as fallback)

## 3. Click to Focus

- [x] 3.1 Add click handler that runs `hyprctl dispatch focuswindow pid:<pid>` to focus the sharing window
- [x] 3.2 Only enable click behavior when PID is known

## 4. Verification

- [x] 4.1 Test with a real screenshare (e.g., Firefox screen share) to verify tooltip and click-to-focus work
