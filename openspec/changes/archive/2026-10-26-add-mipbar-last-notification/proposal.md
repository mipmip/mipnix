## Why

A notification disappears from the screen when its toast closes. The text then
lives only inside the notification daemon: swaync keeps it in its control centre,
but that is a separate surface with its own ordering, and a screenshot's actions
are gone once the toast is no longer floating. A single "last notification"
card helps for the newest message but does not answer the common case: something
arrived a few notifications ago and its content is wanted again.

mipbar has no notification surface of its own. This adds a short history: a bar
button that opens a scrollable list of the most recent notifications, with the
same reopen and annotate controls on every screenshot in the list.

## What Changes

- Add a bell button to the end of the bar, next to the clock.
- Clicking it opens a popover with a scrollable list of recent notifications,
  newest first: application name, how long ago it arrived, summary, body and
  image per card.
- Capture notifications as they are delivered on the session bus, keep at most
  50, and store the list in `~/.cache/mipbar/notifications.json` so a bar restart
  or a new login does not lose it.
- Update an entry when an application replaces a notification, instead of adding
  a second card for the same message.
- For a screenshot notification, clicking the image or the card reveals the file
  in the file manager with that file selected, through the existing
  `shot-reveal-last` script. A separate Bewerken button opens `shot-annotate`.
- Show other notifications read-only. Their actions belong to the application
  that sent them and cannot be invoked from the bar.
- Add a control that clears the whole list, and close the popover on a click
  outside it.
- Leave swaync, its configuration and the screenshot scripts unchanged.

## Capabilities

### New Capabilities

- `mipbar-last-notification`: the notification button, the scrollable list and
  its cards, how notifications are captured and kept across restarts, how
  replacements are handled, which notifications get controls, and what
  activating a screenshot card does.

### Modified Capabilities

None. The screenshot notification keeps its own actions and the reveal keybind
keeps working; the bar adds a second way to reach the same reveal.

## Impact

- `packages/mipbar/widget/Notifications.tsx` (new)
- `packages/mipbar/state/notification.ts` (new), the parsing, text, reply and
  screenshot helpers
- `packages/mipbar/state/notifications.ts` (new), the list state, capture and
  cache around it, so a bar restart does not start a second monitor
- `packages/mipbar/app.ts`, start and stop the capture with the app
- `packages/mipbar/widget/Bar.tsx`, one import and one element before the clock
- `packages/mipbar/style.scss`, the popover, scroller and cards
- `flake.nix`, a headless check for the pure helpers
- `~/.cache/mipbar/notifications.json`, written at runtime

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
