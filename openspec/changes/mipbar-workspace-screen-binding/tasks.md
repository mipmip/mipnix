## 1. Monitor & accent helpers

- [x] 1.1 Add a helper module (e.g. `widget/monitors.ts`) with a user accent config map `{ name: hex }`
- [x] 1.2 Implement `monitorAccent(name, isDark)`: config map first, deterministic name-hash → hue fallback; dark variant = light +0.09 lightness
- [x] 1.3 Implement `deviceType(name)` (`eDP*`/`LVDS*` ⇒ laptop, else monitor)
- [x] 1.4 Implement `portType(name)` (eDP ⇒ internal, HDMI ⇒ HDMI, DP ⇒ DisplayPort; best-effort)
- [x] 1.5 Implement soft-fill helpers (accent @ 15%/26% and 12%/22% alpha)

## 2. Per-workspace underline indicator

- [x] 2.1 In `Workspaces.tsx`, build a reactive `workspaceId → monitorName` map from `hyprland.get_workspaces()` / `get_monitors()`
- [x] 2.2 Refresh that map on `notify::monitors` and `notify::workspaces` (in addition to existing `client-*` signals)
- [x] 2.3 Restructure each workspace button into a vertical `box` (spacing 4px): existing number/icons row + new underline row
- [x] 2.4 Render the underline (14×2.5px, radius 2px) filled with `monitorAccent(boundMonitor)`, on every workspace state
- [x] 2.5 Add SCSS for the underline element in `style.scss`

## 3. Right-click screen picker

- [x] 3.1 Add a `Gtk.GestureClick` (button = 3) to each workspace button, distinct from the primary-click workspace switch
- [x] 3.2 Create the picker component (e.g. `widget/ScreenPicker.tsx`) as a `Gtk.Popover` with `set_pointing_to(button)` (used `set_parent` + `BOTTOM` position — equivalent anchoring)
- [x] 3.3 Render the header `WORKSPACE <N> · BOUND TO SCREEN`
- [x] 3.4 Render one row per `hyprland.get_monitors()` entry
- [x] 3.5 Per row: device image (via `deviceImage(monitor)`), model (description), `SIZE · RES · REFRESH` spec line (size omitted — Hyprland exposes no physical size; shows `RES · REFRESH`), port chip + connector tag
- [x] 3.6 Mark the workspace's current monitor row (CURRENT pill + accent border)
- [x] 3.7 Implement `deviceImage(monitor)` (laptop vs monitor illustration; cairo `DrawingArea`), behind a single helper for later photo swap
- [x] 3.8 Add SCSS + theme tokens for the popover container and rows (light/dark)

## 4. Rebind action

- [x] 4.1 On row select, call the rebind via the hyprland service — used `hyprland.dispatch("moveworkspacetomonitor", "<N> <NAME>")` (the GIR exposes `dispatch(dispatcher, args)` directly; cleaner than `message_async`)
- [x] 4.2 Mark the selected row current and close the popover
- [x] 4.3 Confirm no persistent Hyprland config is written (live-only this change)

## 5. Theme tokens

- [x] 5.1 Add popover/picker light + dark neutrals to `theme.ts` (popover bg/border/text/muted, tile bg/border, connector mono tag, device bezel/stand, screen tints)

## 6. Verification

- [x] 6.1 `mipbar` builds successfully (`nix build .#mipbar` — `ags bundle` type-checks + compiles clean)
- [ ] 6.2 Underline appears on every workspace, coloured per monitor, in both dark and light mode _(live visual check — run the bar)_
- [ ] 6.3 Right-click opens the picker; primary click still switches workspace _(live interaction check)_
- [ ] 6.4 Selecting a monitor moves the workspace (verify with `hyprctl monitors` / visual) and the picker closes _(live interaction check)_
- [ ] 6.5 Underline updates when a monitor is (dis)connected or a workspace is moved _(live hotplug check)_
