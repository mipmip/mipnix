# mipbar Displays Menu

## Purpose

Surface full detail for every attached monitor from the bar, and let the user switch a
monitor's resolution at runtime, without writing any Hyprland configuration and without
ever displaying state that Hyprland has silently disagreed with.

## ADDED Requirements

### Requirement: displays-bar-button

The bar SHALL host a Displays button in its `end` cluster that opens a popover listing
every attached monitor.

#### Scenario: button is always present

- **WHEN** the bar renders
- **THEN** a Displays button SHALL be shown in the `end` cluster
- **AND** it SHALL remain visible regardless of how many monitors are attached

#### Scenario: popover lists every attached monitor

- **WHEN** the user opens the Displays popover
- **THEN** it SHALL show exactly one card per attached monitor

### Requirement: monitor-detail-card

Each monitor card SHALL present the monitor's identity, physical characteristics,
current geometry, and connection state.

#### Scenario: identity and physical size

- **WHEN** a monitor card renders
- **THEN** it SHALL show the monitor's description (make and model)
- **AND** it SHALL show the physical diagonal in inches, derived from the reported
  physical width and height

#### Scenario: current geometry

- **WHEN** a monitor card renders
- **THEN** it SHALL show the current resolution and refresh rate
- **AND** it SHALL show the current scale and the resulting logical size

#### Scenario: pixel density

- **WHEN** a monitor card renders
- **THEN** it SHALL show the native pixel density and the effective density at the
  current scale

#### Scenario: connection and placement

- **WHEN** a monitor card renders
- **THEN** it SHALL show the connector name, a port chip for the port type, the
  monitor's position, and its active workspace

#### Scenario: focused monitor is marked

- **WHEN** a monitor card corresponds to the currently focused monitor
- **THEN** that card SHALL be marked as focused

#### Scenario: non-default state only when relevant

- **WHEN** a monitor has a non-default rotation or is mirroring another monitor
- **THEN** the card SHALL report it
- **WHEN** rotation is default and the monitor is not mirroring
- **THEN** the card SHALL NOT show those fields

### Requirement: resolution-list

Each monitor card SHALL list the resolutions that monitor can be switched to, with the
current one marked.

#### Scenario: one row per resolution

- **WHEN** a monitor card renders its resolution list
- **THEN** it SHALL show one row per distinct resolution the monitor reports as
  available

#### Scenario: refresh rate is not a user choice

- **WHEN** a monitor reports several refresh rates for the same resolution
- **THEN** the list SHALL show that resolution once
- **AND** selecting it SHALL apply the highest refresh rate available for it

#### Scenario: current resolution is marked

- **WHEN** the resolution list renders
- **THEN** the row matching the monitor's current resolution SHALL be marked as current

#### Scenario: native resolution is marked

- **WHEN** a row corresponds to the monitor's native (preferred) resolution
- **THEN** that row SHALL be marked as native

### Requirement: scale-snap-warning

A resolution that cannot be applied at the monitor's current scale SHALL be annotated
with the scale that will be used instead, before the user selects it.

#### Scenario: incompatible resolution is annotated up front

- **WHEN** a listed resolution does not divide evenly by the monitor's current scale
- **THEN** that row SHALL show the scale that will result from selecting it

#### Scenario: compatible resolution is not annotated

- **WHEN** a listed resolution divides evenly by the monitor's current scale
- **THEN** that row SHALL carry no scale warning

### Requirement: runtime-resolution-apply

Selecting a resolution SHALL change that monitor's mode at runtime only.

#### Scenario: apply dispatches a runtime keyword

- **WHEN** the user selects a resolution for a monitor
- **THEN** the system SHALL apply it via a runtime Hyprland `keyword monitor` command

#### Scenario: position and scale are preserved

- **WHEN** a resolution is applied
- **THEN** the monitor's existing position and scale SHALL be passed through rather than
  left to be chosen automatically

#### Scenario: no configuration is written

- **WHEN** a resolution is applied
- **THEN** no Hyprland configuration file SHALL be created or modified
- **AND** the change SHALL NOT survive a Hyprland configuration reload

### Requirement: truthful-read-back

The menu SHALL display monitor state read from Hyprland, never the state that was
requested.

#### Scenario: state is read when the popover opens

- **WHEN** the Displays popover opens
- **THEN** monitor state SHALL be read fresh from Hyprland

#### Scenario: state is re-read after every apply

- **WHEN** a resolution has been applied
- **THEN** monitor state SHALL be read again from Hyprland
- **AND** the cards SHALL be re-rendered from that reading

#### Scenario: a silently substituted scale is surfaced

- **WHEN** Hyprland applies a different scale than the one requested
- **THEN** the card SHALL show the scale and logical size that are actually in effect

#### Scenario: no dependence on monitor change events

- **WHEN** a resolution is applied
- **THEN** the menu SHALL refresh without waiting for a Hyprland monitor event, because
  Hyprland emits none for mode changes

### Requirement: reset-to-configured

The menu SHALL offer a single action returning every monitor to its declared
configuration.

#### Scenario: reset restores declared geometry

- **WHEN** the user activates the reset action
- **THEN** every monitor SHALL return to the resolution, position, and scale declared in
  the Hyprland monitor configuration

#### Scenario: reset refreshes the menu

- **WHEN** the reset action completes
- **THEN** the cards SHALL be re-rendered from freshly read state

### Requirement: repack-layout

The menu SHALL offer an explicit action that closes positional gaps created by a
resolution change.

#### Scenario: re-pack is explicit

- **WHEN** a resolution change leaves a gap between monitors
- **THEN** the layout SHALL NOT be re-packed automatically
- **AND** a re-pack action SHALL be available for the user to invoke

#### Scenario: re-pack removes the gap

- **WHEN** the user invokes the re-pack action
- **THEN** monitors SHALL be repositioned so their logical areas are adjacent

### Requirement: bar-stability-across-changes

Applying a monitor change from the menu SHALL NOT disturb the bar.

#### Scenario: bar survives a resolution change

- **WHEN** a resolution is applied from the menu
- **THEN** the bar SHALL NOT be restarted

#### Scenario: popover stays open

- **WHEN** a resolution is applied from the menu
- **THEN** the Displays popover SHALL remain open, showing the updated state
