## 1. Capture and state

- [x] 1.1 Add `packages/mipbar/state/notification.ts` with the record type and pure `parseNotifyLine` and `parseNotifyReply`, mapping the `Notify` arguments, the action list, the image hint and the daemon-assigned id. Verify with unit tests covering a captured Hyprshot-shaped payload, a replacement, a non-Notify line, a reply and malformed JSON.
- [x] 1.2 Add `packages/mipbar/state/notifications.ts` with the list state, cache read/write and the monitor lifecycle. Start `busctl --user monitor org.freedesktop.Notifications --json=short` once from `app.ts`, respawn it after an exit, and stop it before either bar restart path. Verify with `notify-send` and `pgrep -fc "busctl --user monitor"` after two restarts that only one monitor runs.
- [x] 1.3 Add a Nix check that bundles and runs `state/notification.test.ts` headless, following `checks.mipbar-displays`. Verify with `nix build .#checks.x86_64-linux.mipbar-last-notification`.

## 2. List and persistence

- [x] 2.1 Keep the newest 50 notifications, newest first, in `~/.cache/mipbar/notifications.json`. Write through a temp file and rename, mode 0600, and let an absent or invalid cache yield an empty list. Read the old `last-notification.json` once, migrate it and remove it. Verify with a round-trip test, a truncated cache, a legacy single record and the cap.
- [x] 2.2 Match a new notification's daemon id through the caller unique name and the D-Bus cookie, and replace an existing entry when `replaces_id` is set. Verify with `notify-send -p` followed by `notify-send -r` that the list keeps one updated entry and no duplicate.
- [x] 2.3 Add a clear control that removes every entry and the cache, and close the popover on a click outside. Verify that a cleared list stays empty after a bar restart.

## 3. Bar widget

- [x] 3.1 Add `packages/mipbar/widget/Notifications.tsx` with a menubutton and popover, an empty state, a header with the list title and clear control, and one card per notification with application name, relative time, summary, plain-text body and a bounded image.
- [x] 3.2 Put the cards in a vertical `Gtk.ScrolledWindow` with a bounded content height, so a long list scrolls instead of growing past the screen.
- [x] 3.3 Add screenshot detection from the action shape. Let the card and image call `shot-reveal-last` and a Bewerken control call `shot-annotate`, all through the absolute script paths because the bar does not inherit the Hyprland scripts directory on `PATH`.
- [x] 3.4 Add the widget to `packages/mipbar/widget/Bar.tsx` before the clock and add the popover, scroller and card styles to `packages/mipbar/style.scss`. Verify with `nix build .#mipbar`.

## 4. Integration verification

- [x] 4.1 Run through the spec scenarios with real notifications: several applications in order, expired and dismissed toasts, a replaced notification, a deleted screenshot file, an absent cache and no daemon. Verify each observed result matches the spec.
- [x] 4.2 Confirm after two bar restarts that the list is restored in the same order and that exactly one capture runs. The popover itself is not clicked by the agent; state, cache and the reveal script were verified directly.
- [x] 4.3 Verify `git status` shows no new swaync configuration and no change to `shot-notify`, `shot-reveal-last` or `shot-annotate`.
- [x] 4.4 Run `openspec validate add-mipbar-last-notification`.
- [x] 4.5 Deploy to the home-manager profile, restart the bar and verify that the deployed build shows the list with exactly one capture running.
