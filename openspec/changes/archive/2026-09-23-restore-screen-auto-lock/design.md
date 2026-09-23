## Context

See `proposal.md` for motivation. The constraints that shape the approach:

**This session does not populate `graphical-session.target`.** Hyprland is
started without uwsm or systemd integration, so every systemd user unit that
declares `WantedBy = graphical-session.target` never starts. The repo already
carries two workarounds for this, both documented in
`modules/USERS/pim/programs/hyprland/default.nix`: Walker sets
`systemd.enable = false` and is launched from `autostart.conf`, and
hyprpolkitagent is exec-once'd through a PATH wrapper because its unit crashes
under the restricted unit environment. Any daemon added here inherits the same
constraint.

**PAM state, verified live on `cichorei`:**

```
  /etc/pam.d/
    swaylock          present   (NixOS default, services.xserver/console derived)
    i3lock, vlock, xlock        present
    hyprlock          ABSENT

  hyprlock calls pam_start("hyprlock")
        |
        v
  no service file  ->  falls through to /etc/pam.d/other
        |
        v
  auth required pam_warn.so
  auth required pam_deny.so     every attempt fails, by construction
```

Confirmed in the pinned nixpkgs (`26.05pre-git`, rev `fcb8fcd6`) that
`nixos/modules/programs/wayland/hyprlock.nix:26` is the only place that sets
`security.pam.services.hyprlock`.

**Current sleep-related state on the host:**

```
  IdleAction      = ignore     systemd default, nothing declares it
  IdleActionUSec  = 30min      inert while IdleAction is ignore
  HandleLidSwitch = suspend    systemd default
  sleep.target / suspend.target   available (only nixos-server masks them)
```

So the machine does not sleep on idle today, but only by default, and nothing
locks it when the lid closes.

## Goals / Non-Goals

**Goals:**

- One daemon owns idle policy and sleep-transition policy, so the two cannot
  drift apart.
- Authentication works before any automatic lock is armed.
- The locked path never depends on a component that might silently not be
  running.

**Non-Goals:**

- Routing every lock request through a single DBus door. See the keybind
  decision below; robustness is preferred over elegance here.
- Making the lock screen pretty. Only the box-glyph fault is in scope.

## Decisions

### Order of work: PAM before the timer

The tasks are sequenced so `programs.hyprlock.enable` lands, is rebuilt, and is
manually verified with `SUPER+L` before any automatic trigger exists. Doing it
the other way round means the first automatic lock is also the first test of an
authentication path that is currently guaranteed to fail.

The verification task calls for a second way into the machine (an SSH session,
or a spare VT) to be open while testing. `cichorei` runs `openssh`, so
`pkill hyprlock` over SSH is the escape hatch.

### hypridle over swayidle

`swayidle` can run idle timeouts and has a `before-sleep` hook, so it is not
incapable. hypridle is chosen because:

- It is the Hyprland-native daemon and is in the pinned nixpkgs (0.1.7).
- It answers the logind `Lock` DBus signal, so `loginctl lock-session` becomes a
  working lock verb on this host. That gives a future mipbar Lock button and any
  scripted lock a supported path.
- Its `lock_cmd` / `before_sleep_cmd` / `after_sleep_cmd` triple expresses the
  whole policy in one file rather than as a long shell argument list.

Alternative considered and rejected: keep `swayidle` and add
`before-sleep 'hyprlock'`. It works, but leaves the repo on a Sway-ecosystem
daemon in a Hyprland session for no gain, and does not give the DBus lock verb.

### Started via `exec-once`, not `services.hypridle.enable`

The NixOS module does exactly one useful thing beyond installing the package:

```nix
# nixos/modules/services/wayland/hypridle.nix
systemd.user.services.hypridle.wantedBy = [ "graphical-session.target" ];
```

That target is never reached in this session, so enabling the module would
install a unit that never runs while looking like the daemon is managed. Worse,
it would read as the configured path to anyone reading the repo later. The
package goes into `environment.systemPackages` and `autostart.conf` starts it,
matching the Walker and hyprpolkitagent precedent already set in this repo.

This is a symptom of the missing `graphical-session.target`, which the proposal
records as out of scope. When that is fixed, this decision should be revisited.

### Policy, expressed in `hypridle.conf`

```
general {
    lock_cmd         = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd  = hyprctl dispatch dpms on
}

listener {                      # 10 min: lock, machine stays awake
    timeout    = 600
    on-timeout = loginctl lock-session
}

listener {                      # 15 min: display off, still not sleep
    timeout    = 900
    on-timeout = hyprctl dispatch dpms off
    on-resume  = hyprctl dispatch dpms on
}
```

`pidof hyprlock || hyprlock` is the upstream single-instance guard. Without it a
second lock instance can spawn on top of the first, and killing one leaves the
screen apparently locked but unauthenticatable.

`before_sleep_cmd = loginctl lock-session` is the upstream idiom and is safe
here specifically because hypridle is the process running it, so the DBus
listener is guaranteed alive at that moment. hypridle holds a logind sleep
inhibitor while the command runs, which is what makes the lock land before the
machine goes down rather than after it comes back.

`after_sleep_cmd` exists because some resume paths leave DPMS off, giving a
black screen that reads as a failed wake.

No `on-resume` is set on the lock listener: the screen must stay locked when the
user returns, which is the entire point.

### Keybinds resolve to hyprlock directly, not `loginctl lock-session`

```
  SUPER+L         pidof hyprlock || hyprlock
  SUPER+SHIFT+L   systemctl suspend      (hypridle locks via before_sleep_cmd)
```

`loginctl lock-session` is a no-op with no error when no listener is registered.
If hypridle is not running, a `SUPER+L` bound to it fails silently and leaves an
unlocked screen behind. Calling `hyprlock` directly always locks. hypridle's own
`lock_cmd` is the same string, so both paths converge on one behaviour without
one depending on the other.

`SUPER+SHIFT+L` drops `hyprlock &&` entirely. The old form suspended only after
the user had already unlocked, which is the opposite of the intent; the
before-sleep hook now covers it and covers lid close and `systemctl suspend`
typed by hand at the same time.

### `IdleAction = ignore` declared rather than inherited

```nix
services.logind.settings.Login.IdleAction = "ignore";
```

This changes no running behaviour. It exists so that "the machine does not
suspend itself on idle" is stated in the repo and survives a future change that
might otherwise flip it, and so the intent is discoverable next to the lock
policy instead of being an unwritten reliance on an upstream default.

The option lives under `settings.Login` in the pinned nixpkgs; the old
`extraConfig` form is deprecated there.

### The font fault gets a verification task, not a fix

The bean reports boxes instead of glyphs. On the current host
`fc-match "Noto Sans"` resolves to `NotoSans.ttf` and `fc-list` reports 1200
Noto Sans faces, so the font named in `hyprlock.conf` is present. Writing a fix
now would be guessing at a symptom that may already be gone, and would make the
real cause harder to find if it recurs. The task asks for an observation first,
with a contingency branch if boxes still appear.

## Risks / Trade-offs

- **Lockout during the PAM verification step.** Mitigation: the task sequence
  requires an SSH session open before the first `SUPER+L`, and no automatic
  trigger exists at that point because the timer is armed in a later task.

- **Both hosts change at once.** `desktop-de-hyprland` is shared via
  `role-desktop-pim`. Mitigation: `cichorei` is rebuilt and verified first;
  `doornappel` follows only after the lock is confirmed working.

- **Idle inhibitors weaken the control.** A video player or a conference call
  holds an inhibitor and the screen does not lock. Mitigation: accepted
  deliberately, because `ignore_dbus_inhibit = true` locks the screen mid-meeting
  and would be turned off within a week. If an auditor objects, it is a one-line
  change with a known cost.

- **Display blanking reads as sleep.** At 15 minutes the panel goes dark and the
  machine looks asleep although it is awake. Mitigation: documented in the
  proposal assumptions; dropping the second listener is a two-line revert.

- **hypridle dies and nothing notices.** No supervision exists outside systemd,
  which this session cannot use. Mitigation: none in this change beyond the
  keybind not depending on it. A supervision story arrives with the
  `graphical-session.target` work.

## Migration Plan

1. Land the PAM fix, rebuild `cichorei`, confirm `/etc/pam.d/hyprlock` exists.
2. Verify `SUPER+L` unlocks with the account password, with SSH open.
3. Land the hypridle config and autostart line, reload, confirm the daemon runs.
4. Verify the 10 and 15 minute behaviour, and lid close followed by resume.
5. Rebuild `doornappel`.

Rollback: comment out `exec-once = hypridle` for the idle policy alone, or
revert the whole change. `programs.hyprlock.enable` is safe to keep regardless,
since it only adds an authentication path that should have been there.

## Open Questions

- Whether a written ISO 27001 policy at the organisation names a specific
  timeout. If it names 15 rather than 10, one number in `hypridle.conf` changes
  and no spec requirement changes shape.
