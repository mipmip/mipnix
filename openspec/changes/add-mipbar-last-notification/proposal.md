## Why

A screenshot notification disappears after five seconds. After that the capture
can still be revealed with a keybind, but only the most recent one, and the
notification itself cannot be brought back. For every other application, the
last notification is gone as soon as its toast closes, even though the text is
still somewhere in the notification daemon.

mipbar has no notification surface of its own. This adds the smallest one that
answers the request: a bar button that shows the latest notification and lets a
screenshot from it be reopened.

## What Changes

- Add a bell button to the end of the bar, next to the clock.
- Clicking it opens a popover with the most recent notification: application
  name, how long ago it arrived, summary, body and image.
- Capture notifications as they are delivered on the session bus, and keep the
  latest one in `~/.cache/mipbar/last-notification.json` so a bar restart or a
  new login does not lose it.
- For a screenshot notification, clicking the image or the card reveals the
  file in the file manager with that file selected, through the existing
  `shot-reveal-last` script. A separate Bewerken button opens `shot-annotate`.
- Show other notifications read-only. Their actions belong to the application
  that sent them and cannot be invoked from the bar.
- Add a close button that clears the card, and close the popover on a click
  outside it.
- Leave swaync, its configuration and the screenshot scripts unchanged.

## Capabilities

### New Capabilities

- `mipbar-last-notification`: the bar button, the popover contents, how the
  latest notification is captured and kept across restarts, which
  notifications get controls, and what activating a screenshot card does.

### Modified Capabilities

None. The screenshot notification keeps its own actions and the reveal keybind
keeps working; the bar adds a second way to reach the same reveal.

## Impact

- `packages/mipbar/widget/LastNotification.tsx` (new)
- `packages/mipbar/state/notification.ts` (new), the parsing, text and
  screenshot helpers
- `packages/mipbar/state/lastNotification.ts` (new), the capture and cache
  around it, so a bar restart does not start a second monitor
- `packages/mipbar/widget/Bar.tsx`, one import and one element before the clock
- `packages/mipbar/style.scss`, the popover and card
- `~/.cache/mipbar/last-notification.json`, written at runtime

No new package. `busctl` is part of systemd, which every host already has, and
the screenshot scripts are already installed by the Hyprland module.

Constraints:

- The capture reads `Notify` calls on the session bus. It therefore depends on
  the notification daemon following the freedesktop interface, not on which
  daemon is installed.
- A generic notification's action ids have meaning only to its sender. The bar
  cannot replay them, which is why only screenshot cards get buttons.
- Opening the file manager from the bar has no activation token, the same as the
  reveal keybind. The window can therefore open behind the focused window.
