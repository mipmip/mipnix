# Mipnix Integration

## ADDED Requirements

### Requirement: mipbar-nix-package

Mipbar SHALL be built as a nix package in `perSystem.packages.mipbar` in the mipnix flake.

#### Scenario: package builds

WHEN `nix build .#mipbar` is run in the mipnix directory
THEN a mipbar binary SHALL be produced

### Requirement: home-manager-module

A home-manager module SHALL install the mipbar package and configure it for the user.

#### Scenario: module adds package

WHEN the mipbar home-manager module is enabled
THEN the mipbar binary SHALL be available in the user's PATH

### Requirement: autostart-replaces-ashell

Mipbar SHALL start automatically with Hyprland, replacing ashell.

#### Scenario: hyprland starts

WHEN Hyprland starts
THEN mipbar SHALL be launched via `exec-once`
AND ashell SHALL NOT be launched

### Requirement: dev-workflow

The mipbar source directory SHALL support live development via `ags run .` using hm-ricing-mode symlinks.

#### Scenario: dev iteration

WHEN the developer runs `ags run .` in the mipbar source directory
THEN the bar SHALL start with the current source code
AND changes to source files SHALL be testable by restarting `ags run .`

### Requirement: source-location

Mipbar source (including beans and openspec artifacts) SHALL reside at `~/mipnix/packages/mipbar/`.

#### Scenario: source moved

WHEN the migration is complete
THEN all mipbar source files SHALL exist at `~/mipnix/packages/mipbar/`
AND `~/cExperimental/mipbar/` SHALL no longer be the active source
