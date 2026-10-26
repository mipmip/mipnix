## 1. Capture and cache

- [x] 1.1 Add `packages/mipbar/state/notification.ts` with the normalized record type and a pure `parseNotifyLine` that accepts one `busctl` JSON line, rejects lines that are not a `Notify` method call, and maps the arguments and hints. Verify with unit tests covering the captured Hyprshot-shaped payload, a non-Notify line and malformed JSON.
- [x] 1.2 Add cache read and write to `packages/mipbar/state/lastNotification.ts`: `~/.cache/mipbar/last-notification.json`, temp file plus rename, mode 0600, and a missing or invalid file yielding an empty state. Verify with a round-trip test and a test that feeds truncated JSON.
- [x] 1.3 Add the monitor lifecycle: start `busctl --user monitor org.freedesktop.Notifications --json=short` once from `app.ts`, respawn it if it exits, and expose the record as state. Verify with `notify-send` that one notification updates the state, and with `pgrep -fc "busctl --user monitor"` after two bar restarts that only one monitor runs.
- [x] 1.4 Add a Nix check that bundles and runs `state/notification.test.ts` headless, following `checks.mipbar-displays`. Verify with `nix build .#checks.x86_64-linux.mipbar-last-notification`.

## 2. Bar widget

- [x] 2.1 Add `packages/mipbar/widget/LastNotification.tsx` with a menubutton and popover, an empty state, a header with application name and relative time, summary and plain-text body, and a bounded image. Verify by opening it with no cache and with a captured notification.
- [x] 2.2 Add screenshot detection from the action shape and image path, with the card and image calling `shot-reveal-last` and a Bewerken control calling `shot-annotate`. Verify with a fresh capture and with an older screenshot card after a newer notification has arrived.
- [x] 2.3 Add the clear control, which removes the cache and returns to the empty state, and close the popover on a click outside. Verify that a cleared card stays empty after a bar restart.
- [x] 2.4 Add the widget to `packages/mipbar/widget/Bar.tsx` before the clock and add the popover and card styles to `packages/mipbar/style.scss`. Verify with `nix build .#mipbar`.

## 3. Integration verification

- [x] 3.1 Run through the spec scenarios with real notifications: generic application, screenshot, expired toast, replaced notification, deleted screenshot file, and no daemon running. Verify each observed result matches the spec.
- [x] 3.2 Verify `git status` shows no new swaync configuration and no change to `shot-notify`, `shot-reveal-last` or `shot-annotate`.
