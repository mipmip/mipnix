## 1. Dependencies

- [x] 1.1 Ensure `brightnessctl` is available in mipbar's runtime PATH (check mipbar nix module, add to extraPackages if needed)

## 2. Brightness Slider Component

- [x] 2.1 Add `BrightnessSlider` function to `QuickSettingsPanel.tsx` that polls `brightnessctl -m` every 1s, parses the percentage, and renders a slider with `display-brightness-symbolic` icon
- [x] 2.2 Implement `onChangeValue` handler that calls `brightnessctl -e4 -n2 set <value>%` via `execAsync`
- [x] 2.3 Hide the brightness section when `brightnessctl -m` returns no device (graceful fallback for desktops)

## 3. Panel Layout

- [x] 3.1 Add `BrightnessSlider` to `QuickSettingsPanel` between `VolumeSliders` and `WifiStatus`, with a `Gtk.Separator` above it
