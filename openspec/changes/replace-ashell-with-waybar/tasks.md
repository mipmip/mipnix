# Tasks: replace-ashell-with-waybar

## Implementation Tasks

- [x] 1. **Review current waybar configuration**
  - [x] 1.1 Read `modules/users/pim/programs/hyprland/waybar/config.jsonc`
  - [x] 1.2 Verify it matches user requirements (desktop switcher left, active app center, systray/time/power/wifi right)
  - [x] 1.3 Identify any modules to remove or adjust

- [x] 2. **Update waybar configuration if needed**
  - [x] 2.1 Adjust `modules-right` to match user preferences
  - [x] 2.2 Ensure proper ordering: tray, network (wifi), battery (power), clock (time/date)
  - [x] 2.3 Remove modules user didn't request (cpu, backlight, pulseaudio)

- [x] 3. **Update Hyprland autostart**
  - [x] 3.1 Edit `modules/users/pim/programs/hyprland/hypr/autostart.conf`
  - [x] 3.2 Replace `exec-once = ashell` with `exec-once = waybar`

- [x] 4. **Verify waybar package availability**
  - [x] 4.1 Check if waybar is already included in user pim's packages
  - [x] 4.2 Add waybar to system packages in `modules/programs/desktop/de/hyprland.nix`

## Validation Tasks

- [x] 5. **Test configuration syntax**
  - [x] 5.1 Nix files validated successfully
  - [ ] 5.2 Stage all changes (user handles git operations)

- [ ] 6. **Build and test**
  - [ ] 6.1 Run `./RUNME.sh up_home` to apply home-manager configuration
  - [ ] 6.2 Verify waybar launches on Hyprland startup
  - [ ] 6.3 Confirm all requested elements are visible and functional

- [ ] 7. **Verify behavior**
  - [ ] 7.1 Verify ashell is no longer auto-starting
  - [ ] 7.2 Confirm waybar displays desktop switcher, active app, systray, time/date, power, and wifi
  - [ ] 7.3 Test clicking on workspaces to switch desktops
