## MODIFIED Requirements

### Requirement: laptop-workspaces-stay-on-panel

Workspaces 8, 9, and the workspace labelled "0" (id 10) SHALL remain on the laptop
panel `eDP-1`. The reconciliation SHALL address that third workspace by its real id
(10), so the binding actually applies and is observable in `hyprctl workspaces`.

#### Scenario: external present

- **WHEN** an external monitor is connected alongside the laptop
- **THEN** workspaces 8, 9, 10 SHALL be on `eDP-1` and workspaces 1–7 SHALL be on the
  external monitor

#### Scenario: reconciliation targets an addressable workspace

- **WHEN** the reconciliation dispatches `moveworkspacetomonitor` for the laptop
  workspace set
- **THEN** every dispatched workspace id SHALL be one Hyprland can address (8, 9, 10),
  and none SHALL be the inert id `0` whose dispatch failure was previously hidden by
  output redirection
