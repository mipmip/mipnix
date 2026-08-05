## 1. Minimized widget

- [x] 1.1 Add `packages/mipbar/widget/Minimized.tsx`, modeled on `Workspaces.tsx`
      (AstalHyprland) + `SshKey.tsx` (menubutton/popover): read the workspace named
      `special:minimized` via `get_workspaces()`/`get_clients()`; hold the list in
      `createState`.
- [x] 1.2 Refresh the list/count on the Hyprland signals `Workspaces.tsx` uses
      (`client-added`, `client-removed`, `client-moved`, `notify::workspaces`).
- [x] 1.3 Render a `menubutton` in the bar: `visible` bound to count > 0
      (hide-when-empty); label shows an icon + the count.
- [x] 1.4 Popover: one `StatusRow` per minimized window (app icon via `lookupIcon`
      + title); clicking a row restores that window
      (`movetoworkspace <currentWsId>,address:<addr>` then `focuswindow`). Add a
      "Restore all" action.

## 2. Bar integration & styling

- [x] 2.1 `Bar.tsx`: import `Minimized` and add `<Minimized />` to the `end` `<box>`.
- [x] 2.2 `style.scss`: add `.Minimized` StatusIcon styling and `.MinimizedPopover`,
      matching the existing popover / `StatusRow` idiom.

## 3. Build & verify

- [x] 3.1 `nix build .#mipbar` compiles (stage the new file so the flake source
      sees it).
- [x] 3.2 With windows minimized (currently 2 are in `special:minimized`): confirm
      the indicator appears with the correct count.
- [x] 3.3 Click a row: confirm the window returns to the current workspace and is
      focused, and the count decrements.
- [x] 3.4 Restore the last one: confirm the indicator hides.
- [x] 3.5 "Restore all": confirm every minimized window returns.
