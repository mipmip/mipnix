# hyprland-status-bar Specification

## Purpose
Defines the status bar configuration for Hyprland window manager, providing workspace navigation, active application information, and system status indicators.

## Requirements

### ADDED Requirement: Waybar as Primary Status Bar
The system SHALL use waybar as the primary status bar for user pim's Hyprland environment.

#### Scenario: Waybar autostart on Hyprland
- **GIVEN** user pim is using Hyprland as their desktop environment
- **WHEN** Hyprland starts
- **THEN** waybar SHALL be automatically launched via `exec-once = waybar` in autostart.conf
- **AND** waybar SHALL display at the top of the screen

#### Scenario: No ashell in autostart
- **GIVEN** waybar is configured as the status bar
- **WHEN** Hyprland autostart configuration is evaluated
- **THEN** ashell SHALL NOT be present in exec-once commands
- **AND** ashell configuration MAY remain in the module for potential future use but SHALL NOT be automatically started

### ADDED Requirement: Waybar Layout Configuration
The system SHALL configure waybar with desktop switcher on the left, active application info in the center, and system indicators on the right.

#### Scenario: Desktop switcher on left
- **GIVEN** waybar is running
- **WHEN** the waybar configuration is loaded
- **THEN** modules-left SHALL contain "hyprland/workspaces"
- **AND** the workspaces module SHALL display all Hyprland workspaces
- **AND** clicking a workspace SHALL activate that workspace

#### Scenario: Active application info in center
- **GIVEN** waybar is running
- **WHEN** an application window is focused in Hyprland
- **THEN** modules-center SHALL contain "hyprland/window"
- **AND** the window module SHALL display the active window title
- **AND** when no window is active, the center SHALL be empty

#### Scenario: System indicators on right
- **GIVEN** waybar is running
- **WHEN** the waybar configuration is loaded
- **THEN** modules-right SHALL contain at minimum: "tray", "network", "battery", "clock"
- **AND** "tray" SHALL display the system tray for background applications
- **AND** "network" SHALL display wifi connection status
- **AND** "battery" SHALL display power/battery status
- **AND** "clock" SHALL display current time and date
- **AND** modules SHALL be ordered from left to right with clock as the rightmost element

### ADDED Requirement: Waybar Configuration Files
The system SHALL maintain waybar configuration in the user's Home Manager module under a dedicated waybar subdirectory.

#### Scenario: Waybar configuration location
- **GIVEN** user pim has Hyprland configured
- **WHEN** Home Manager evaluates the pim-hyprland module
- **THEN** waybar configuration files SHALL be sourced from `modules/users/pim/programs/hyprland/waybar/`
- **AND** the directory SHALL contain at minimum `config.jsonc` and `style.css`
- **AND** files SHALL be deployed to `~/.config/waybar/` via home.file
- **AND** waybar configuration SHALL be included in hm-ricing-mode for safe testing
