# hyprland-quick-settings Specification

## Purpose
Provides a quick settings control center for Hyprland, allowing users to quickly adjust system settings (audio, brightness, network, bluetooth, power) via a popup panel without opening full applications.

## ADDED Requirements

### Requirement: nwg-panel Quick Settings Integration
The system SHALL provide a quick settings panel using nwg-panel for user pim's Hyprland environment.

#### Scenario: nwg-panel package installed
- **GIVEN** user pim is using Hyprland
- **WHEN** the system configuration is applied
- **THEN** nwg-panel package SHALL be installed and available
- **AND** nwg-panel configuration SHALL be deployed to `~/.config/nwg-panel/`

#### Scenario: Quick settings accessible via keybinding
- **GIVEN** user pim is in a Hyprland session
- **WHEN** the user presses the quick settings keybinding (e.g., SUPER + A)
- **THEN** nwg-panel SHALL display a popup panel with controls module
- **AND** the panel SHALL show audio, brightness, network, bluetooth, and power controls
- **AND** pressing the keybinding again or losing focus SHALL close the panel

#### Scenario: Quick settings accessible via waybar icon
- **GIVEN** user pim is in a Hyprland session
- **AND** waybar is displaying at the top
- **WHEN** the user clicks the quick settings icon in waybar (top right, before clock)
- **THEN** nwg-panel SHALL display a popup panel with controls module
- **AND** the panel SHALL show audio, brightness, network, bluetooth, and power controls
- **AND** clicking the icon again or losing focus SHALL close the panel

#### Scenario: No conflict with waybar
- **GIVEN** waybar is running as the status bar
- **WHEN** nwg-panel is launched via keybinding
- **THEN** nwg-panel SHALL appear as a popup overlay
- **AND** nwg-panel SHALL NOT conflict with waybar's display or functionality
- **AND** both tools SHALL coexist without visual or functional issues

### Requirement: Quick Settings Controls Module
The system SHALL configure nwg-panel with a controls module providing access to common system settings.

#### Scenario: Audio controls available
- **GIVEN** nwg-panel quick settings is open
- **WHEN** the controls module is displayed
- **THEN** audio volume controls SHALL be visible
- **AND** user SHALL be able to adjust volume levels
- **AND** user SHALL be able to mute/unmute audio
- **AND** audio output device selection SHOULD be available

#### Scenario: Brightness controls available
- **GIVEN** nwg-panel quick settings is open
- **AND** the device has a backlight (laptop)
- **WHEN** the controls module is displayed
- **THEN** brightness controls SHALL be visible
- **AND** user SHALL be able to adjust screen brightness

#### Scenario: Network controls available
- **GIVEN** nwg-panel quick settings is open
- **AND** NetworkManager is running
- **WHEN** the controls module is displayed
- **THEN** network/wifi controls SHALL be visible
- **AND** user SHALL be able to view available networks
- **AND** user SHALL be able to connect to wifi networks

#### Scenario: Bluetooth controls available
- **GIVEN** nwg-panel quick settings is open
- **AND** bluetooth service is running
- **WHEN** the controls module is displayed
- **THEN** bluetooth controls SHALL be visible
- **AND** user SHALL be able to toggle bluetooth on/off
- **AND** user SHALL be able to view and connect to bluetooth devices

#### Scenario: Power settings available
- **GIVEN** nwg-panel quick settings is open
- **AND** the device has battery (laptop)
- **WHEN** the controls module is displayed
- **THEN** power/battery status SHALL be visible
- **AND** power management options SHOULD be accessible

### Requirement: nwg-panel Configuration Management
The system SHALL maintain nwg-panel configuration in user pim's Home Manager module.

#### Scenario: Configuration deployment
- **GIVEN** user pim has nwg-panel module configured
- **WHEN** Home Manager applies the configuration
- **THEN** nwg-panel config files SHALL be deployed to `~/.config/nwg-panel/`
- **AND** configuration SHALL enable controls module
- **AND** configuration SHALL set panel to popup mode (not persistent)
- **AND** configuration SHALL position panel appropriately (top-right or bottom-right)

#### Scenario: On-demand launch only
- **GIVEN** Hyprland is starting
- **WHEN** autostart commands are executed
- **THEN** nwg-panel SHALL NOT be launched automatically
- **AND** nwg-panel SHALL only be launched via keybinding or waybar icon click
- **AND** nwg-panel SHALL close when not in use to save resources

### Requirement: Waybar Quick Settings Icon Integration
The system SHALL provide a clickable quick settings icon in waybar that triggers nwg-panel.

#### Scenario: Quick settings icon in waybar
- **GIVEN** waybar is configured and running
- **WHEN** waybar is displayed
- **THEN** a quick settings icon SHALL be visible in the top right section
- **AND** the icon SHALL be positioned before the clock module
- **AND** the icon SHALL be after battery module
- **AND** the icon order SHALL be: tray, network, battery, quicksettings, clock

#### Scenario: Icon triggers nwg-panel
- **GIVEN** waybar quick settings icon is visible
- **WHEN** user clicks the quick settings icon
- **THEN** nwg-panel SHALL launch with controls module displayed
- **AND** the panel SHALL appear as a popup near the icon
- **AND** clicking the icon again SHALL toggle the panel closed

#### Scenario: Icon styling and tooltip
- **GIVEN** waybar quick settings icon is configured
- **WHEN** the icon is displayed
- **THEN** the icon SHALL use an appropriate symbol (e.g., "󰒓" or "")
- **AND** hovering over the icon SHALL display tooltip "Quick Settings"
- **AND** the icon SHALL follow waybar's styling theme
