# Tasks: add-nwg-panel-quick-settings

## Implementation Tasks

- [x] 1. **Add nwg-panel package**
  - [x] 1.1 Add nwg-panel to system packages in `modules/programs/desktop/de/hyprland.nix`
  - [x] 1.2 Verify package availability in nixpkgs

- [x] 2. **Create nwg-panel Home Manager module**
  - [x] 2.1 Create directory `modules/users/pim/programs/nwg-panel/`
  - [x] 2.2 Create `default.nix` with flake-parts structure
  - [x] 2.3 Add module to imports in `modules/users/pim/hm-pim.nix`

- [x] 3. **Configure nwg-panel settings**
  - [x] 3.1 Create nwg-panel configuration directory structure
  - [x] 3.2 Create `config` file with controls module enabled
  - [x] 3.3 Configure controls module with audio, brightness, network, bluetooth, power widgets
  - [x] 3.4 Set panel mode to popup (layer: overlay, not persistent)
  - [x] 3.5 Configure panel position (top)
  - [x] 3.6 Deploy configuration to `~/.config/nwg-panel/` via home.file

- [x] 4. **Add Hyprland keybinding**
  - [x] 4.1 Choose appropriate keybinding (SUPER + A for quick settings)
  - [x] 4.2 Add keybinding to Hyprland binds.conf to launch nwg-panel
  - [x] 4.3 Document keybinding in comments

- [x] 5. **Add waybar quick settings icon**
  - [x] 5.1 Edit `modules/users/pim/programs/hyprland/waybar/config.jsonc`
  - [x] 5.2 Add "custom/quicksettings" to modules-right (before clock)
  - [x] 5.3 Configure custom module with icon ("󰒓")
  - [x] 5.4 Set on-click action to launch nwg-panel
  - [x] 5.5 Add tooltip text "Quick Settings"
  - [x] 5.6 Update waybar style.css for custom module styling

- [x] 6. **Configure nwg-panel for on-demand mode**
  - [x] 6.1 Ensure nwg-panel is NOT in autostart (only triggered by keybinding or waybar click)
  - [x] 6.2 Configure panel to close when clicked (click-closes: true in config)

## Validation Tasks

- [ ] 7. **Test configuration syntax**
  - [ ] 7.1 Verify Nix syntax for all modified files
  - [ ] 7.2 Check nwg-panel config syntax
  - [ ] 7.3 Verify waybar config.jsonc syntax
  - [ ] 7.4 Stage all changes (user handles git operations)

- [ ] 8. **Build and verify package**
  - [ ] 8.1 Run `./RUNME.sh up_home` to apply home-manager configuration
  - [ ] 8.2 Verify nwg-panel package is installed
  - [ ] 8.3 Check nwg-panel config files are deployed to `~/.config/nwg-panel/`
  - [ ] 8.4 Verify waybar reloads with new quick settings icon

- [ ] 9. **Test quick settings functionality**
  - [ ] 9.1 Test keybinding opens nwg-panel
  - [ ] 9.2 Test waybar icon click opens nwg-panel
  - [ ] 9.3 Verify waybar icon appears in correct position (before clock)
  - [ ] 9.4 Verify controls module displays correctly
  - [ ] 9.5 Test volume controls work
  - [ ] 9.6 Test brightness controls work
  - [ ] 9.7 Test network/wifi controls work
  - [ ] 9.8 Test bluetooth controls work (if bluetooth enabled)
  - [ ] 9.9 Verify panel closes when expected
  - [ ] 9.10 Confirm no conflicts with waybar

- [ ] 10. **Documentation**
  - [ ] 10.1 Document keybinding usage
  - [ ] 10.2 Document waybar icon functionality
  - [ ] 10.3 Note any system service dependencies
