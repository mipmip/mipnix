<!-- Bean: .beans/mipnix-nhpf--fix-lock-screen-and-enable-timer-again.md -->

## Why

The Hyprland session has no automatic screen lock. ISO 27001 clear-screen
control (A.7.7) requires an unattended workstation to lock itself and to demand
authentication before it can be used again. Neither half holds today.

Three separate defects stack on top of each other, and the order in which they
are fixed matters.

**1. The idle timer is commented out.** It was added on 2025-12-02 (`ccd4f902`)
as a single `swayidle` line that locked after 5 minutes and blanked the display
after 10. On 2026-02-10, commit `3232c43d` swapped ashell for noctalia-shell and
commented out both `swayidle` and `swaync` in the same edit. `swaync` was
restored later; the idle line was not. It has sat dead at
`modules/USERS/pim/programs/hyprland/hypr/autostart.conf:7` ever since.

**2. `hyprlock` cannot authenticate at all.** There is no `/etc/pam.d/hyprlock`
on any host in this repo. PAM falls back to `/etc/pam.d/other` when a named
service file is missing, and on NixOS `other` is `pam_warn` followed by
`pam_deny`, so every password attempt fails by construction. NixOS ships default
PAM stacks for `i3lock`, `vlock`, `xlock` and `swaylock`, but hyprlock's stack
only appears via `programs.hyprlock.enable`, which this repo never sets;
`modules/programs/desktop/de/hyprland.nix:89` drops the binary into
`environment.systemPackages` and nothing more.

This is the bean's "password is not enough" bullet, and it turns the timer into
a hazard: arming a 10 minute lock before fixing PAM would lock the session with
no way back in short of a VT switch or an SSH session that kills hyprlock.

**3. Nothing locks on suspend.** `HandleLidSwitch` is at the logind default
`suspend`, and no hook locks the session before sleeping. Closing the lid and
reopening it hands back an unlocked desktop. For a clear-screen control this is
a wider hole than the missing idle timer, because closing the lid is the gesture
most people use when they walk away.

A fourth, smaller defect turned up alongside them: `binds.conf:40` reads
`hyprlock && systemctl suspend`. `hyprlock` blocks until the session is
unlocked, so the suspend fires after the user comes back rather than before they
leave.

## What Changes

- **Give hyprlock a PAM stack.** Set `programs.hyprlock.enable = true` in the
  Hyprland NixOS module, which installs `security.pam.services.hyprlock` and the
  package, and drop the now-redundant `hyprlock` entry from
  `environment.systemPackages`.
- **Replace `swayidle` with `hypridle`** as the idle daemon, started by
  `exec-once` and configured from a new repo-owned `hypr/hypridle.conf`.
  hypridle holds a logind sleep inhibitor, which is what makes lock-before-sleep
  possible; `swayidle` was only ever wired for idle timeouts here.
- **Arm the timers**: lock at 10 minutes of inactivity, power the display down
  at 15 minutes. Neither suspends the machine.
- **Lock before every sleep**, whatever triggers it (lid close, the keybind, a
  manual `systemctl suspend`), and restore the display on resume.
- **Pin `IdleAction = ignore` declaratively** so the machine never suspends on
  idle. This is already the running value, but only because it is the systemd
  default. Declaring it makes "my computer does not fall asleep on its own" a
  property of the repo rather than an accident.
- **Fix the lock-and-suspend keybind** to suspend directly and let hypridle's
  before-sleep hook do the locking, which removes the inverted sequence.
- **Verify the box-glyph symptom** from the bean rather than blind-fixing it.
  `fc-match "Noto Sans"` now resolves and 1200 Noto Sans faces are installed, so
  the rendering fault has likely aged out. A contingency task covers it if it
  has not.

## Capabilities

### Added Capabilities

- `screen-lock`: the session locks itself after a bounded idle period, locks
  before any sleep transition, demands authentication to return, and never
  suspends the machine on idle.

## Impact

- `modules/programs/desktop/de/hyprland.nix`: add `programs.hyprlock.enable`,
  add `hypridle` to the package list, remove `hyprlock` and `swayidle` from
  `environment.systemPackages`, add `services.logind.settings.Login.IdleAction`.
- `modules/USERS/pim/programs/hyprland/hypr/hypridle.conf`: new file.
- `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`: replace the dead
  `swayidle` comment with `exec-once = hypridle`.
- `modules/USERS/pim/programs/hyprland/hypr/binds.conf`: fix the `SUPER+SHIFT+L`
  sequence; add the single-instance guard to `SUPER+L`.
- Blast radius: `desktop-de-hyprland` sits in `role-desktop-pim`, so this lands
  on `cichorei` and `doornappel` together. That is intended; the control applies
  to both.

## Out of Scope

- Populating `graphical-session.target`. The NixOS `services.hypridle` module
  binds its user unit to that target, which this session does not populate (the
  same reason Walker and hyprpolkitagent use `exec-once`, documented in
  `modules/USERS/pim/programs/hyprland/default.nix`). Moving the session to uwsm
  so systemd user units work is a worthwhile separate change, not this one.
- Restyling `hyprlock.conf`. Only the rendering fault from the bean is in scope.
- Fingerprint authentication. Neither `cichorei` nor `doornappel` imports a
  fingerprint module (only `lavendel-laptop` and `_lego2-laptop` do) and
  `fprintd.service` does not exist on this host, so the bean's "always finger
  unlock needed" was a lavendel observation. Re-check it there once PAM works.
- Locking the GDM/GNOME session. GNOME is installed alongside Hyprland but is
  not the session in daily use.

## Assumptions

These were open questions during exploration. They are answered here so the
change is actionable; each is cheap to revise.

- **10 minutes to lock**, taken from the bean. No written policy number was
  available to match against. Display off follows at 15.
- **The display still powers down.** Turning the panel off is not sleep, the
  machine stays awake and reachable. If a black screen is unwanted, drop the
  second listener and leave the lock screen lit.
- **Lid close keeps suspending.** `HandleLidSwitch` stays at `suspend`, because
  closing the lid is a deliberate act and matches the stated intent of sleeping
  only on request. The gap it opened is closed by locking before the sleep, not
  by refusing to sleep.
- **Idle inhibitors are respected.** A full-screen video keeps the session
  awake. This is standard desktop behaviour and the alternative locks the screen
  during a meeting.
