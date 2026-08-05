## Context

The Hyprland session on lego2 is launched by GDM and runs without uwsm/systemd
session integration — it does **not** populate `graphical-session.target`. This
is already documented in `modules/USERS/pim/programs/hyprland/default.nix` (the
reason Walker is started via `exec-once` rather than its systemd user service).

`security.polkit.enable = true` is set (in the Hyprland desktop module) and the
polkit **Authority** (`org.freedesktop.PolicyKit1`) runs system-wide. Fingerprint
is fully configured: `services.fprintd` is enabled, prints are enrolled, and
`/etc/pam.d/polkit-1` lists `pam_fprintd.so` as `auth sufficient` ordered before
`pam_unix` — so a polkit prompt tries fingerprint first, password as fallback.

The missing piece was purely a **polkit authentication agent** in the session:
the Authority can authorize actions, but without a registered agent there is no
UI to collect the user's authentication, so prompts never appear.

## Goals / Non-Goals

**Goals:**
- Have a polkit authentication agent running for the whole Hyprland session.
- Make polkit-mediated prompts (Bitwarden system-auth/biometric unlock, and any
  other privileged GUI action) appear and be satisfiable — including by
  fingerprint.
- Fit the existing session-autostart pattern; keep nix-store paths out of the
  static `autostart.conf`.

**Non-Goals:**
- Configuring Bitwarden itself (biometric unlock was already enabled in its
  settings; the app-side toggle greying is Bitwarden's normal locked-state
  behavior, not something this change controls).
- Changing polkit policy, PAM, or fprintd (all already correct).
- Adopting uwsm/systemd session integration for Hyprland.

## Decisions

### Use `hyprpolkitagent`

The Hyprland-native Qt6 polkit agent. Chosen over `polkit-gnome` /
`lxqt-policykit` / `mate-polkit` to match the Hyprland stack; any registered
agent would satisfy the requirement, but the native one is the natural fit.

### Launch via `exec-once`, not the systemd user unit

The package ships a `hyprpolkitagent.service` user unit
(`WantedBy=graphical-session.target`, `ConditionEnvironment=WAYLAND_DISPLAY`).
Two independent reasons rule it out:

1. **It crashes.** Started via the unit, the Qt6 agent aborts (`SIGABRT` /
   core-dump) — the unit's restricted service environment lacks the session's
   Qt/Wayland integration. Verified: launched directly from the session
   (inheriting `WAYLAND_DISPLAY`/`DISPLAY`/session D-Bus) it runs and registers
   fine; started via the unit it core-dumps and hits systemd's start-limit.
2. **It would not auto-start.** This session does not populate
   `graphical-session.target`, so a `WantedBy` that target never fires.

`exec-once` inherits the working session environment — the same mechanism and
rationale as Walker/mipbar in this config.

### PATH wrapper to avoid a hardcoded store path

`hyprpolkitagent` installs only a `libexec` binary (no `bin/`), so
`exec-once = hyprpolkitagent` would not resolve on PATH, and hardcoding
`/nix/store/…/libexec/hyprpolkitagent` in the static `autostart.conf` would break
on every package update. Instead the home-manager module adds a
`writeShellScriptBin "hyprpolkitagent-start"` wrapper that execs the libexec
binary; `autostart.conf` invokes the stable name.

## Risks / Trade-offs

- **[Resolved] systemd-unit crash.** Documented above; the direct `exec-once`
  launch avoids it.
- **[Trade-off] Not managed by systemd.** No automatic restart-on-failure that a
  user service would give. Acceptable and consistent with the rest of this
  session's autostart (Walker/mipbar are the same); the agent is stable once up.
- **[Note] Single agent.** Only one polkit agent should register per session;
  this config adds exactly one and no other agent is started elsewhere.

## Alternatives Considered

- **`systemctl --user start hyprpolkitagent.service`** — tried first; rejected
  because the Qt6 agent core-dumps under the unit environment (see Decisions).
- **`polkit-gnome` / `lxqt-policykit`** — would work, but `hyprpolkitagent` is
  the native fit for this stack.
- **Adopting uwsm** so the systemd user unit auto-starts — out of scope; a much
  larger session-management change for a one-line autostart need.
