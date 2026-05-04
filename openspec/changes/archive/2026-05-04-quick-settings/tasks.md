# Tasks: Quick Settings Panel

## 1. NixOS Modules (lego2)

- [x] 1.1 Add `hardware.bluetooth.enable = true` and `hardware.bluetooth.powerOnBoot = true` to lego2 configuration
- [x] 1.2 Add `services.blueman.enable = true` to lego2 configuration
- [x] 1.3 Verify WirePlumber is running (check if `services.pipewire.wireplumber.enable` is needed or already defaulted)
- [ ] 1.4 Rebuild NixOS (`sudo nixos-rebuild switch`)

## 2. Flake Build Deps

- [x] 2.1 Add `wireplumber` and `bluetooth` to `mipbar-astalPackages` in `flake.nix`
- [ ] 2.2 Re-enter dev shell to verify new packages are available

## 3. QuickSettings Trigger Widget

- [x] 3.1 Create `widget/QuickSettings.tsx` with a `<menubutton>` containing wifi icon + battery icon/percentage
- [x] 3.2 Move wifi logic from `Wifi.tsx` into QuickSettings trigger
- [x] 3.3 Move battery logic from `Battery.tsx` into QuickSettings trigger
- [x] 3.4 Delete `widget/Wifi.tsx` and `widget/Battery.tsx`
- [x] 3.5 Update `widget/Bar.tsx` — replace `<Wifi />` and `<Battery />` with `<QuickSettings />`

## 4. Quick Settings Panel

- [x] 4.1 Create `widget/QuickSettingsPanel.tsx` as the popover content
- [x] 4.2 Add toggle row: wifi on/off, bluetooth on/off, airplane mode
  - [x] 4.2.1 Wifi toggle bound to `AstalNetwork` wifi enabled state
  - [x] 4.2.2 Bluetooth toggle bound to `AstalBluetooth` adapter powered state
  - [x] 4.2.3 Airplane mode toggle via `rfkill block all` / `rfkill unblock all`
- [x] 4.3 Add volume sliders
  - [x] 4.3.1 Speaker slider bound to `AstalWp` default audio sink volume
  - [x] 4.3.2 Mic slider bound to `AstalWp` default audio source volume
- [x] 4.4 Add wifi status row: current network name + button to open nmtui in terminal
- [x] 4.5 Add bluetooth status row: on/off label + "Pair" button to open `blueman-manager`
- [x] 4.6 Add action buttons row: lock (`hyprlock`), sleep (`systemctl suspend`), screenshot (`hyprshot -m region`)

## 5. Styling

- [x] 5.1 Add `.QuickSettings` trigger styles (combined wifi+battery area)
- [x] 5.2 Add `.QuickSettingsPanel` popover styles
- [x] 5.3 Style toggle buttons (active/inactive states)
- [x] 5.4 Style volume sliders
- [x] 5.5 Style action buttons

## 6. Verify

- [ ] 6.1 Run `ags run app.ts` and confirm wifi+battery appear as single clickable area
- [ ] 6.2 Click trigger and confirm popover opens with all sections
- [ ] 6.3 Test wifi toggle
- [ ] 6.4 Test bluetooth toggle and pair button opens blueman
- [ ] 6.5 Test airplane mode toggle
- [ ] 6.6 Test volume sliders adjust speaker and mic
- [ ] 6.7 Test nmtui button opens terminal with nmtui
- [ ] 6.8 Test lock, sleep, screenshot action buttons
- [ ] 6.9 Build with `nix build .#mipbar` and verify packaged version works
