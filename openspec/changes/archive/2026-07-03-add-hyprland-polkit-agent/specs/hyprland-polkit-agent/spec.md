# Hyprland Polkit Agent

## ADDED Requirements

### Requirement: polkit-agent-runs-in-session

A polkit authentication agent SHALL run in the Hyprland graphical session so
that polkit-mediated authentication requests can be presented to the user. The
agent SHALL be `hyprpolkitagent`, started at session start.

#### Scenario: agent present after login

- **WHEN** the user logs into the Hyprland session
- **THEN** `hyprpolkitagent` SHALL be running and connected to the session bus,
  so polkit has a registered authentication agent for the session

#### Scenario: privileged GUI action gets a prompt

- **WHEN** an application triggers a polkit-authorized action in the session
  (e.g. Bitwarden system-authentication unlock, or another privileged GUI action)
- **THEN** an authentication dialog SHALL be presented, rather than the request
  failing silently for lack of an agent

#### Scenario: fingerprint offered where enrolled

- **WHEN** the polkit authentication dialog is shown and a fingerprint is
  enrolled (`services.fprintd`, `pam_fprintd` first in the `polkit-1` PAM stack)
- **THEN** the dialog SHALL accept a fingerprint, with the password as fallback

### Requirement: agent-launched-directly-not-via-systemd-unit

The agent SHALL be launched directly from the Hyprland session environment (via
`exec-once`), NOT via its systemd user unit, because the Qt6 agent crashes under
the unit's restricted environment.

#### Scenario: launched via exec-once with session environment

- **WHEN** the session autostart runs the agent
- **THEN** it SHALL be started with `exec-once` so it inherits the session
  environment (`WAYLAND_DISPLAY`, `DISPLAY`, session D-Bus), under which it runs
  correctly

#### Scenario: systemd unit start is avoided

- **WHEN** the agent would otherwise be started by its `hyprpolkitagent.service`
  systemd user unit
- **THEN** that path SHALL NOT be used, because the unit's restricted environment
  causes the Qt6 agent to abort (`SIGABRT`); additionally this session does not
  populate `graphical-session.target`, so the unit would not auto-start anyway

### Requirement: no-hardcoded-store-path-in-static-config

The static Hyprland `autostart.conf` SHALL NOT contain a nix-store path for the
agent binary. Because the package ships only a `libexec` binary (no `bin/`), a
PATH wrapper SHALL be provided so `autostart.conf` can reference a stable name.

#### Scenario: stable wrapper name in autostart

- **WHEN** `autostart.conf` launches the agent
- **THEN** it SHALL invoke a stable command name (`hyprpolkitagent-start`)
  provided on PATH by the home-manager module, which execs the package's
  `libexec` binary — so the config survives package updates without edits
