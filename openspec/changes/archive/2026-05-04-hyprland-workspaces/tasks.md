# Tasks: Hyprland Workspaces Navigation

## 1. Add Hyprland Library

- [x] 1.1 Add `hyprland` to `astalPackages` in `flake.nix`
- [x] 1.2 Verify the library is available by entering the dev shell

## 2. Create Workspaces Widget

- [x] 2.1 Create `widget/Workspaces.tsx` with a component that imports `AstalHyprland`
- [x] 2.2 Get the Hyprland singleton and read workspaces
- [x] 2.3 Filter to only occupied workspaces (clients.length > 0) with positive IDs
- [x] 2.4 Sort workspaces by ID within each monitor group
- [x] 2.5 Group workspace buttons by monitor name, each group in its own box
- [x] 2.6 Render each workspace as a button showing its ID
- [x] 2.7 Add click handler to call `workspace.focus()` on each button
- [x] 2.8 Add `focused` CSS class to the active workspace button, bound reactively
- [x] 2.9 Subscribe to workspace and client change signals to re-render the list

## 3. Integrate into Bar

- [x] 3.1 Import Workspaces component in `widget/Bar.tsx`
- [x] 3.2 Wrap the start section in a `<box>` containing AppLauncher button and Workspaces component
- [x] 3.3 Ensure start box aligns to start with no expand

## 4. Style Workspace Buttons

- [x] 4.1 Add base styles for workspace buttons in `style.scss`
- [x] 4.2 Add pill-style highlight for the `focused` class (distinct background, border-radius)
- [x] 4.3 Add hover state for workspace buttons
- [x] 4.4 Add visual separation (gap/margin) between monitor groups

## 5. Verify

- [x] 5.1 Run `ags run .` and confirm workspace buttons appear next to launcher
- [x] 5.2 Confirm only occupied workspaces are shown
- [x] 5.3 Confirm active workspace has pill highlight
- [x] 5.4 Click a workspace and confirm it switches
- [x] 5.5 Open/close windows and confirm workspace buttons update reactively
