## 1. Monitor-hotplug workspace re-homing (Bug 1)

- [ ] 1.1 Add a listener script in `modules/USERS/pim/programs/hyprland/hypr/scripts/`
      that subscribes to Hyprland `socket2` and parses `monitoradded` / `monitorremoved`
      events
- [ ] 1.2 On each event, query `hyprctl monitors -j`, select the first monitor whose name
      is not `eDP-1` as the "external" target
- [ ] 1.3 Re-home workspaces 1–7 onto the external monitor via
      `hyprctl dispatch moveworkspacetomonitor <ws> <monitor>`; ensure 8/9/0 on `eDP-1`
- [ ] 1.4 Perform an initial reconciliation pass on script startup (handle the
      already-connected-at-login case), then enter the event loop
- [ ] 1.5 Handle the external-removed case: workspaces 1–7 fall back to `eDP-1`
- [ ] 1.6 Launch the script via `exec-once` in `autostart.conf`
- [ ] 1.7 Document in the hypr config that the runtime listener owns the
      workspace→monitor binding and nwg-displays owns geometry

## 2. Workspace 0 keybind unification (Bug 2)

- [ ] 2.1 In `binds.conf`, change `MOD+0` from `workspace, 10` to `workspace, 0`
- [ ] 2.2 In `binds.conf`, change `MOD+SHIFT+0` from `movetoworkspace, 10` to
      `movetoworkspace, 0`

## 3. Verification

- [ ] 3.1 With external as `DP-2`: confirm workspaces 1–7 are on the external monitor
      and apps open there by default
- [ ] 3.2 Simulate/confirm the `DP-3` (other-location) case re-homes correctly without
      config edits
- [ ] 3.3 Hotplug test: connect/disconnect external after login; confirm workspaces move
      and fall back correctly
- [ ] 3.4 Press `MOD+0`, open an app, confirm it lands on workspace id 0 and the mipbar
      "0" button shows its icon
- [ ] 3.5 Confirm cursor / default focus returns to the external monitor when present
