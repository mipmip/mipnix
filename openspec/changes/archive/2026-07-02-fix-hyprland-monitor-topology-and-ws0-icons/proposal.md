## Why

Since the last NixOS upgrade, the Hyprland monitor/workspace topology drifted from
reality, producing two user-facing bugs:

1. **External workspaces get stranded on the laptop.** Workspaces 1–7 are pinned to
   the connector name `DP-3` in `workspaces.conf`. The user has one external monitor
   at a time, but it is a *different* physical monitor at home vs. work and plugs into
   a different HDMI port, so it enumerates as `DP-2` or `DP-3` depending on location.
   When the external monitor comes up under a connector name that does not match the
   pinned `DP-3`, workspaces 1–7 have no valid home. The laptop (`eDP-1`, which holds
   the other `default:true` workspace, ws8) becomes the dominant/default focus target,
   new windows open centered on the laptop, and the user must manually drag apps back
   onto the external screen.

2. **Workspace "0" shows no app icons in mipbar.** Three places disagree on what "0"
   means: the keybind `MOD+0` dispatches `workspace 10` (id 10), `workspaces.conf`
   declares `workspace=0` (id 0) on `eDP-1`, and the mipbar workspace button for "0"
   queries id 0. Windows sent via the keyboard land on id 10, but the bar reads id 0
   (empty), so no icons ever render for that button.

Related tasks: [mipbar-mmke](.beans/mipbar-mmke--show-app-icons-per-workspace.md),
[mipbar-4c78](.beans/mipbar-4c78--create-hyprland-workspaces-navigation.md)

## What Changes

- **Bug 1 — port-agnostic external workspaces.** Add a runtime Hyprland event listener
  (socket2) that, on monitor add/remove, re-homes workspaces 1–7 onto whichever monitor
  is *not* the laptop (`eDP-1`), and keeps 8/9/0 on `eDP-1`. This corrects the
  workspace→monitor binding regardless of the external monitor's connector name or
  identity, so it works at home and at work without per-location edits.
- **Bug 1 — coexistence with nwg-displays.** nwg-displays continues to own monitor
  geometry (`monitors.conf`) and the static `workspaces.conf`; the runtime listener
  overrides the binding at connect time, so regenerating with nwg-displays does not
  reintroduce the stranding bug.
- **Bug 2 — unify workspace 0.** Change `binds.conf` so `MOD+0` dispatches
  `workspace 0` and `MOD+SHIFT+0` dispatches `movetoworkspace 0` (instead of `10`),
  matching the declared `workspace=0` on `eDP-1` and the mipbar button that queries
  id 0. Icons then render for workspace 0.

## Capabilities

### New Capabilities

- `hyprland-monitor-topology`: Bind "external" workspaces (1–7) to whatever external
  monitor is connected, independent of connector name, via a runtime monitor-hotplug
  listener; keep laptop workspaces (8, 9, 0) on `eDP-1`.

### Modified Capabilities

- `hyprland-workspace-zero`: Resolve the three-way identity mismatch so the workspace
  reachable by `MOD+0` is the same workspace id (0) that mipbar previews, restoring app
  icons for workspace 0.

## Impact

- `modules/USERS/pim/programs/hyprland/hypr/scripts/`: new monitor-hotplug listener
  script (re-homes workspaces 1–7 to the non-`eDP-1` monitor).
- `modules/USERS/pim/programs/hyprland/hypr/autostart.conf`: `exec-once` to launch the
  listener.
- `modules/USERS/pim/programs/hyprland/hypr/binds.conf`: `MOD+0` and `MOD+SHIFT+0`
  retargeted from `10` to `0`.
- `modules/USERS/pim/programs/hyprland/hypr/workspaces.conf`: nwg-managed; left as-is
  (runtime listener corrects binding). Documented as intentionally not hand-edited.
- No mipbar code change required for bug 2 (the button already queries id 0).
