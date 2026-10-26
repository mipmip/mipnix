## 1. Hyprland keybinds

- [x] 1.1 `modules/USERS/pim/programs/hyprland/hypr/binds.conf:68` — change
      `bind = $mainMod, 0, workspace, 0` to `workspace, 10`.
- [x] 1.2 `binds.conf:80` — change `bind = $mainMod SHIFT, 0, movetoworkspace, 0` to
      `movetoworkspace, 10`.

## 2. Static workspace declaration

- [x] 2.1 `modules/USERS/pim/programs/hyprland/hypr/workspaces.conf:12` — change
      `workspace=0,monitor:eDP-1` to `workspace=10,monitor:eDP-1`.

## 3. Monitor reconciliation

- [x] 3.1 `modules/USERS/pim/programs/hyprland/scripts/workspace-monitor-rehome` —
      change `LAPTOP_WS="8 9 0"` to `LAPTOP_WS="8 9 10"`.
- [x] 3.2 Update the script's header comment block, which documents the mapping as
      `workspaces 8/9/0 -> always the laptop panel eDP-1`.

## 4. mipbar: separate label from id

- [x] 4.1 `packages/mipbar/widget/Workspaces.tsx` — replace `WORKSPACE_IDS` (a number
      list) with a list of `{ id, label }`, the tenth entry being
      `{ id: 10, label: "0" }`.
- [x] 4.2 Add `label` to the `WorkspaceItem` type; use `id` for `workspaceMap.get`,
      for the `hyprctl dispatch workspace ${id}` click handler, and for
      `openScreenPicker(…, item.id)`; use `label` only for the rendered
      `<label label={…} />`.
- [x] 4.3 Change `LAPTOP_IDS` from `new Set([8, 9, 0])` to `new Set([8, 9, 10])` and
      the group-separator test from `id === 8` (unchanged — still 8, verify).

## 5. Verification

> `~/.config/hypr/*` are Nix-store symlinks, so 5.1–5.3 and 5.5–5.8 only become
> testable after a home-manager switch (which triggers `hyprctl reload` via the
> activation hook in `modules/USERS/pim/programs/hyprland/default.nix:15`). The
> build-level equivalents are recorded under 5.4.

- [ ] 5.1 After rebuild + Hyprland reload: press `MOD+0`, confirm
      `hyprctl activeworkspace -j` reports `"id": 10`.
- [ ] 5.2 Press `MOD+SHIFT+0` with a focused window; confirm `hyprctl clients -j`
      shows that window's `workspace.id` as 10.
- [ ] 5.3 `hyprctl workspaces -j` reports a workspace with id 10 (it did not report
      id 0 before this change, despite `workspaces.conf` declaring it).
- [x] 5.4 Grep the four config sites for a bare `0` workspace id; confirm none remain
      (satisfies the `no configuration names workspace id 0` scenario).
      → All four clean. Additionally verified at the build level: the home-manager
      store snapshot that would be deployed carries `workspace, 10` /
      `movetoworkspace, 10` (binds.conf:68,80), `workspace=10,monitor:eDP-1`
      (workspaces.conf), and `LAPTOP_WS="8 9 10"` (rehome script). `nix build .#mipbar`
      succeeds with the label/id split.
- [ ] 5.5 With an external monitor connected, run the rehome `reconcile` and confirm
      `hyprctl workspaces -j` shows id 10 on `eDP-1`. Pre-fix baseline recorded in
      the proposal: id 10 was stranded on `HDMI-A-1`.
- [ ] 5.6 Click the mipbar "0" button; confirm it switches to id 10 and that the
      button reads "0" (not "10").
- [ ] 5.7 Open a window on the workspace labelled 0; confirm its icon appears on the
      mipbar "0" button — the original symptom the 2026-07-02 change set out to fix
      and did not.
- [ ] 5.8 Confirm the "0" button still carries the laptop accent and sits after the
      group separator (regression check on the `LAPTOP_IDS` move).
