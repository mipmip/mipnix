# Tasks: System Tray

## 1. Add Tray Library

- [x] 1.1 Add `tray` to `astalPackages` in `flake.nix`
- [x] 1.2 Re-enter dev shell to pick up the new package

## 2. Create Tray Widget

- [x] 2.1 Create `widget/Tray.tsx` importing `AstalTray`
- [x] 2.2 Get the tray singleton and bind to `items` reactively
- [x] 2.3 Render each item as a `<menubutton>` with the item's `gicon`
- [x] 2.4 Wire up `menuModel` and `actionGroup` via init callback
- [x] 2.5 Subscribe to `actionGroup` changes on each item to keep menus in sync

## 3. Integrate into Bar

- [x] 3.1 Import Tray component in `widget/Bar.tsx`
- [x] 3.2 Add Tray between Screenshare and the clock menubutton in the end box

## 4. Style Tray Icons

- [x] 4.1 Add base styles for tray icons in `style.scss`

## 5. Verify

- [x] 5.1 Run `ags run .` and confirm tray icons appear for running apps
- [x] 5.2 Click a tray icon and confirm the app's context menu appears
- [x] 5.3 Start/stop a tray app and confirm icons update reactively
