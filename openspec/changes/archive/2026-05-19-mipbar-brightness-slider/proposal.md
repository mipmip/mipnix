## Why

The laptop brightness can only be adjusted via keyboard shortcuts (`XF86MonBrightnessUp/Down`), which use `brightnessctl` under the hood. There is no visual slider in the mipbar quick settings panel, making it inconsistent with volume control (which has sliders) and harder to set a precise brightness level.

Related task: [mipnix-jk8v](.beans/mipnix-jk8v--mipbar-add-screen-brightness.md)

## What Changes

- Add a brightness slider to the quick settings panel, placed between the volume sliders and wifi status sections
- Add `brightnessctl` as a dependency to the mipbar module
- Use `brightnessctl` via `execAsync` for reading and setting brightness (no Astal backlight library exists upstream)
- Poll brightness periodically to stay in sync with keyboard shortcut changes

## Capabilities

### New Capabilities
- `screen-brightness`: Brightness slider control for the laptop screen in the quick settings panel

### Modified Capabilities
- `quick-settings-panel`: Panel layout gains a brightness slider section between volume sliders and wifi status

## Impact

- **Files modified**: `packages/mipbar/widget/QuickSettingsPanel.tsx`, `flake.nix` or mipbar nix module (to ensure `brightnessctl` is available at runtime)
- **Dependencies**: `brightnessctl` (already installed system-wide for keybinds, but needs to be accessible from mipbar's runtime)
- **No breaking changes**
