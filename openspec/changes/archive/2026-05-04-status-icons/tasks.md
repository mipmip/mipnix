# Tasks: Status Icons

## 1. Add Libraries

- [x] 1.1 Add `network` and `battery` to `astalPackages` in `flake.nix`
- [x] 1.2 Re-enter dev shell to pick up new packages

## 2. Create WiFi Widget

- [x] 2.1 Create `widget/Wifi.tsx` importing `AstalNetwork`
- [x] 2.2 Bind wifi icon to `iconName` property reactively
- [x] 2.3 Hide widget when no wifi device is available

## 3. Create Battery Widget

- [x] 3.1 Create `widget/Battery.tsx` importing `AstalBattery`
- [x] 3.2 Display battery icon bound to `iconName`
- [x] 3.3 Display percentage text bound to `percentage`
- [x] 3.4 Hide widget when battery is not present (`isPresent`)

## 4. Create Screenshare Widget

- [x] 4.1 Create `widget/Screenshare.tsx` importing `AstalHyprland`
- [x] 4.2 Listen to Hyprland `event` signal for `screencast` events
- [x] 4.3 Track screenshare state (on/off) reactively
- [x] 4.4 Show icon only when screenshare is active, hidden otherwise

## 5. Integrate into Bar

- [x] 5.1 Import all three widgets in `widget/Bar.tsx`
- [x] 5.2 Restructure end section as a `<box>` with: Wifi, Battery, Screenshare, Clock
- [x] 5.3 Align end box to end

## 6. Style Status Icons

- [x] 6.1 Add base styles for status icons in `style.scss`
- [x] 6.2 Add screenshare active indicator style (e.g., red/accent color)

## 7. Verify

- [x] 7.1 Run `ags run .` and confirm wifi icon appears
- [x] 7.2 Confirm battery icon + percentage shows (on laptop) or hides (on desktop)
- [x] 7.3 Start a screenshare and confirm indicator appears
- [x] 7.4 Stop screenshare and confirm indicator disappears
