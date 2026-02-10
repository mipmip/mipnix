# Tasks: add-theme-wallpapers

## Implementation Order

1. [ ] Create `resources/wallpapers-dark/` directory
2. [ ] Create `resources/wallpapers-light/` directory
3. [ ] Move existing wallpapers to appropriate theme folder (or copy to both as placeholder)
4. [ ] Create `scripts/theme-wallpaper` script that:
   - Accepts `dark` or `light` argument
   - Updates wpaperd config with correct path
   - Reloads wpaperd wallpaper
5. [ ] Update `binds.conf` to call theme-wallpaper script from dark/light keybindings
6. [ ] Update `wpaperd/config.toml` to use dark wallpapers by default
7. [ ] Test keybinding flow: `SUPER+D` switches to dark wallpaper, `SUPER+SHIFT+D` to light

## Verification

- Press `SUPER+D` and confirm wallpaper changes to a dark-themed image
- Press `SUPER+SHIFT+D` and confirm wallpaper changes to a light-themed image
- Verify GTK4 theme still switches correctly alongside wallpaper

## Dependencies

- wpaperd must be running (already in autostart.conf)
- No new Nix packages required
