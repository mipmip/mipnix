## 1. Monitor Selection Logic

- [x] 1.1 Add a `getPreferredMonitor()` function in `app.ts` that returns the first non-eDP monitor, or falls back to the first monitor
- [x] 1.2 Change startup to create a single bar on the preferred monitor instead of one per monitor

## 2. Hotplug Handling

- [x] 2.1 Connect to `Gdk.Display` monitor list `items-changed` signal in `app.ts`
- [x] 2.2 On monitor change: destroy the current bar window and recreate on the new preferred monitor

## 3. Window Identity

- [x] 3.1 Give each bar window a unique name based on the monitor connector to prevent conflicts

## 4. Verification

- [x] 4.1 Verify mipbar builds successfully
- [x] 4.2 Test hotplug by connecting/disconnecting an external monitor
