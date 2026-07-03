## 1. Monitor-hotplug workspace re-homing (Bug 1)

- [x] 1.1 Added `modules/USERS/pim/programs/hyprland/scripts/workspace-monitor-rehome` (the scripts dir is `./scripts`, delivered to `~/.config/hypr/scripts/` — not `hypr/scripts/`). It reads Hyprland `socket2` via `socat` and matches `monitoradded`/`monitorremoved` (incl. v2 variants).
- [x] 1.2 `external_monitor()` queries `hyprctl monitors -j | jq` and picks the first monitor whose name is not `eDP-1`.
- [x] 1.3 `reconcile()` moves ws 1–7 to the external monitor and 8/9/0 to `eDP-1` via `hyprctl dispatch moveworkspacetomonitor`.
- [x] 1.4 `reconcile` runs once on startup (already-connected case) before entering the socket2 event loop.
- [x] 1.5 External-removed: when no non-eDP-1 monitor exists, all workspaces fall back to `eDP-1`.
- [x] 1.6 Added `exec-once = ~/.config/hypr/scripts/workspace-monitor-rehome` in `autostart.conf`. Also added `socat` to the hyprland desktop module's `environment.systemPackages` (the script's runtime dependency; `jq` was already declared) — verified present in lego2's built system path.
- [x] 1.7 Documented (comment in autostart.conf + script header) that the listener owns the workspace→monitor binding and nwg-displays owns geometry.

## 2. Workspace 0 keybind unification (Bug 2)

- [x] 2.1 `binds.conf`: `MOD+0` changed from `workspace, 10` to `workspace, 0`.
- [x] 2.2 `binds.conf`: `MOD+SHIFT+0` changed from `movetoworkspace, 10` to `movetoworkspace, 0`.

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
