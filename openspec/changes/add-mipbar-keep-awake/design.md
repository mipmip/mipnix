## Context

See proposal.md for motivation. The constraints that decided the approach, all
of them already in the repository:

- `hypr/hypridle.conf` owns the idle policy: lock at 600s, `dpms off` at 900s.
  It is started from `exec-once` in `autostart.conf`, not from
  `services.hypridle.enable`.
- The machine never suspends on inactivity. `screen-lock`'s `no-idle-suspend`
  requires logind's idle action to be declared `ignore`. So "prevent sleep" on
  this machine means preventing the lock and the blank, not preventing suspend.
- hypridle 0.1.7 honours three inhibit sources, each with its own opt-out:
  `ignore_dbus_inhibit`, `ignore_systemd_inhibit` and `ignore_wayland_inhibit`.
  `hypridle.conf` sets none of them, so all three are respected.
- `Super+Shift+L` is bound to `systemctl suspend`, and hypridle's
  `before_sleep_cmd` locks ahead of it.
- mipbar widgets are AGS/Astal components. The house style, visible in
  `SshKey.tsx`, is to poll the real state on an interval and refresh
  immediately after an action, rather than to hold the truth in the widget.

## Goals / Non-Goals

**Goals:**

- One click to suspend the idle timers, one click to give them back.
- The inhibit is inspectable with standard tooling, not only through the bar.
- Restarting the bar neither loses the inhibit nor lies about it.

**Non-Goals:**

- Changing `hypridle.conf`, logind, or any Nix module. The control is a runtime
  lock; the policy it suspends stays exactly as declared.
- Blocking suspend, lid close, or a manual lock.
- Timed variants ("for an hour"). The mechanism supports them cheaply and they
  can be added later without changing anything here.

## Decisions

### A logind idle inhibit, not the Wayland protocol and not killing hypridle

hypridle accepts three kinds of inhibit. The logind one wins on inspectability:
`systemd-inhibit --list` shows it next to every other lock on the machine, with
a holder and a reason, so an unexplained absence of locking is one command away
from an explanation.

Rejected: the Wayland `idle-inhibit-unstable-v1` protocol. It is the most direct
route, since Hyprland stops reporting idle while an inhibitor surface exists,
but it needs a surface-bound binding that Astal does not expose, and it is
invisible to anything that is not the compositor.

Rejected: stopping hypridle. It leaves the session with no lock policy at all
until something starts it again, which is a security regression rather than a
feature, and nothing then shows that the policy is missing.

### `--what=idle` and nothing else

Adding `sleep` to the same lock would block an explicit `systemctl suspend`,
which is bound to `Super+Shift+L`. The keybind would appear to do nothing, with
the cause three layers away from the symptom. Keep-awake and refuse-to-suspend
are different requests, and only the first was asked for.

Lid close and manual lock are untouched for the same reason: they are explicit
user requests, and an idle inhibit has no business overriding them.

### A transient user unit, not a child of the bar

```
  systemd-run --user --unit=mipbar-caffeine \
    systemd-inhibit --what=idle --who=mipbar --why='Keep awake (mipbar)' \
      --mode=block sleep infinity
```

Holding the lock in a child process of the bar would tie it to the bar's
lifetime, so a reload would drop the inhibit silently while the icon was still
being rebuilt. A named unit survives the reload, and it gives the widget
something to read its state back from:

```
  on       systemd-run --user --unit=mipbar-caffeine ...
  off      systemctl --user stop mipbar-caffeine
  state    systemctl --user is-active mipbar-caffeine
```

Rejected: tracking the state in the widget. It is the same mistake `SshKey.tsx`
documents at length, where the displayed state and the real state drift apart
after any action that did not go through the widget.

### `reset-failed` before every start

`systemd-run --unit=<name>` refuses a name that is still held by a failed unit.
Without clearing it first, the toggle would do nothing on the next click after
any failure, and the icon would flip back to off with no explanation. One
`systemctl --user reset-failed` ahead of the start removes the whole class.

### Poll every 5s as well as refreshing after a click

The click path refreshes immediately, so the icon is right as soon as the action
lands. The interval covers everything else: the unit stopped from a terminal,
the unit exiting on its own, a bar that started while the inhibit was already
held. Five seconds matches the other indicators in the bar.

## Risks / Trade-offs

- **hypridle's `ignore_systemd_inhibit` default is load-bearing.** → Setting it
  in `hypridle.conf` would make the toggle silently do nothing. The widget says
  so where it takes the lock, which is where someone would look.
- **The unit outlives the bar.** → Intended, but quitting the bar with the
  toggle on leaves the inhibit held. It is visible in `systemd-inhibit --list`
  and dies with the session.
- **The bar can hold the screen unlocked indefinitely.** → That is the feature,
  and it is why the control shows its state in the bar at all times rather than
  behind a popover. It does not survive the session, so the worst case is
  bounded by a logout.
- **A widget state of "off" cannot distinguish "not inhibited" from "cannot
  talk to systemd".** → Both leave the idle policy in force, which is the safe
  reading, so the two are not worth separating.

## Migration Plan

None. Nothing is replaced, no file is rewritten, and the control starts off.
Reverting is removing the widget and its two call sites; any inhibit left
running dies with the session or with one `systemctl --user stop`.
