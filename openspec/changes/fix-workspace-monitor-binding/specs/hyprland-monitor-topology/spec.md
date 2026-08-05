# Hyprland Monitor Topology

## MODIFIED Requirements

### Requirement: reconcile-on-hotplug-and-startup

The workspace→monitor binding SHALL be reconciled when a monitor is added or
removed at runtime, once at session startup, **and when a workspace 1–7 is focused
or created**, so the binding is correct without requiring a relogin and without
depending on a monitor event to trigger it. The reconciliation SHALL guard against
self-triggered event loops (the moves it dispatches may themselves emit workspace
events).

#### Scenario: monitor hotplugged after login

- **WHEN** an external monitor is connected after the session has already started
- **THEN** workspaces 1–7 SHALL move to the external monitor automatically

#### Scenario: external already connected at login

- **WHEN** the external monitor is already connected before the session starts
- **THEN** the binding SHALL be reconciled on startup so workspaces 1–7 are on the
  external monitor without manual intervention

#### Scenario: external monitor removed

- **WHEN** the external monitor is disconnected
- **THEN** workspaces 1–7 SHALL fall back to the laptop panel `eDP-1`

#### Scenario: workspace focused without a monitor event

- **WHEN** the user switches to (or creates) a workspace in the 1–7 range while an
  external monitor is connected, without any monitor being added or removed
- **THEN** that workspace SHALL end up on the external monitor, reconciled by the
  workspace-focus/create trigger rather than waiting for a monitor event

#### Scenario: reconciliation does not loop

- **WHEN** the reconciliation moves workspaces between monitors (which can emit
  further workspace events)
- **THEN** it SHALL NOT re-trigger itself into a loop (e.g. via debounce or a
  self-trigger guard)

### Requirement: coexist-with-nwg-displays

The static Hyprland configuration SHALL NOT pin workspaces 1–7 to a monitor
connector name, because the external connector varies by location (`DP-2`/`DP-3`)
and a build-time static file cannot express "the connected external monitor". The
runtime reconciliation SHALL be the sole owner of the workspace→monitor binding for
workspaces 1–7. nwg-displays owns monitor geometry (`monitors.conf`); it does not
own the 1–7 binding.

#### Scenario: no stale connector pin in static config

- **WHEN** the Hyprland configuration is loaded
- **THEN** workspaces 1–7 SHALL have no `monitor:<connector>` rule in
  `workspaces.conf`, so no dead-connector rule can strand them on the laptop when
  the named connector is absent

#### Scenario: laptop workspaces keep their stable pin

- **WHEN** the static configuration pins workspaces 8, 9, 0 to `eDP-1`
- **THEN** that pin SHALL remain, because `eDP-1` (the laptop panel) is a stable
  connector, unlike the variable external connector

#### Scenario: external monitor enumerates under any connector name

- **WHEN** the connected external monitor enumerates as `DP-2`, `DP-3`, or any
  other non-`eDP-1` connector
- **THEN** workspaces 1–7 SHALL be placed on it by the runtime reconciliation,
  with no per-connector configuration
