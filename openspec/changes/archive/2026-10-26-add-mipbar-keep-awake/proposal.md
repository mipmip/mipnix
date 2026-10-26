## Why

The idle policy in `hypridle.conf` is deliberately strict: lock at 10 minutes,
power the panel down at 15. That is right for an unattended laptop and wrong
for the cases where the machine is doing something the input devices cannot see,
such as watching a long build, reading a document, or presenting. The only ways
out today are to keep touching the keyboard or to kill hypridle, and the second
leaves the session with no lock policy at all until it is started again by hand.

This adds the espresso/caffeine control the bar was missing: one click suspends
the idle timers, one click gives them back.

## What Changes

- Add a keep-awake toggle to mipbar, next to the ssh key indicator, showing a
  coffee cup when idle is inhibited and a crossed-out cup when it is not.
- Hold the inhibit as a logind idle lock in a transient user unit, which
  hypridle honours because `ignore_systemd_inhibit` is left at its default.
- Inhibit `idle` only. Inhibiting `sleep` as well would make the same lock
  block an explicit `systemctl suspend`, so asking the machine to stay awake
  would quietly break the suspend binding on `Super+Shift+L`.
- Read the toggle's state back from systemd rather than tracking it in the
  widget, so a bar reload does not lose it and a `systemctl --user stop` typed
  by hand is reflected in the icon.
- Record that the idle lock timer now has a deliberate exception. The machine
  still never suspends on inactivity; what the toggle holds off is the lock and
  the display blank.

## Capabilities

### New Capabilities

- `keep-awake-toggle`: the bar control that suspends the idle lock and display
  blank on request, how the inhibit is held, what it deliberately does not
  inhibit, and how its state survives a bar reload.

### Modified Capabilities

- `screen-lock`: `idle-lock-timer` currently says the session locks itself after
  inactivity with no user action involved. That stays true by default, but there
  is now a way to suspend it on purpose, and the requirement has to say so
  rather than be quietly contradicted.

## Impact

- `packages/mipbar/widget/Caffeine.tsx` (new)
- `packages/mipbar/widget/Bar.tsx`, one import and one element
- `packages/mipbar/style.scss`, the on and off colours for the glyph
- No change to `hypridle.conf`, to logind, or to any Nix module: the inhibit is
  a runtime lock, not configuration.

Constraints:

- Depends on hypridle keeping `ignore_systemd_inhibit` at its default. Setting
  it would make the toggle silently do nothing, so the default is load-bearing
  and worth a comment where it matters.
- The transient unit outlives the bar. That is the point, but it means quitting
  the bar while the toggle is on leaves the inhibit in place until the unit is
  stopped.
