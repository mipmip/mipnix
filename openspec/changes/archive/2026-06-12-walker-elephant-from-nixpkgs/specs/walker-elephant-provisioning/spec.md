# Walker Elephant Provisioning

## ADDED Requirements

### Requirement: provisioned-from-official-nixpkgs

Walker and Elephant SHALL be provisioned from official nixpkgs/home-manager, with no `walker` or `elephant` flake inputs in `flake.nix`.

#### Scenario: no upstream flake inputs

- **WHEN** the flake is evaluated
- **THEN** there SHALL be no `walker` or `elephant` flake input, and the lock SHALL NOT contain their private nixpkgs trees

#### Scenario: packages come from nixpkgs

- **WHEN** the home configuration is built
- **THEN** Walker SHALL resolve to `pkgs.walker` and Elephant to `pkgs.elephant` from the project's nixpkgs (26.05)

### Requirement: walker-via-home-manager-module

Walker SHALL be installed via the official home-manager `services.walker` module (for the package and config) and launched via Hyprland autostart.

#### Scenario: walker module enabled, systemd trigger off

- **WHEN** the home configuration is built and activated
- **THEN** `services.walker` SHALL be enabled with `systemd.enable = false` (the systemd user service is `WantedBy graphical-session.target`, which this non-systemd-integrated Hyprland session does not populate, so it would never auto-start)

#### Scenario: walker launched via autostart

- **WHEN** the Hyprland session starts
- **THEN** Walker SHALL be started via `exec-once = walker --gapplication-service` in `autostart.conf`

### Requirement: elephant-package-default-config

Elephant SHALL be installed as the `pkgs.elephant` package and run with its default configuration (no bespoke home-manager elephant module config).

#### Scenario: elephant available on PATH

- **WHEN** the home configuration is activated
- **THEN** the `elephant` command SHALL be available on PATH from `pkgs.elephant`

### Requirement: launcher-still-works

The launcher SHALL continue to function after migration — invoking `walker` (via the mipbar button or keybind) opens a working launcher backed by Elephant.

#### Scenario: launcher returns results

- **WHEN** the user opens the launcher (mipbar button or `SPACE` keybind)
- **THEN** Walker SHALL appear and return results from its Elephant backend (not an empty launcher)

### Requirement: obsolete-cache-removed

The `walker.cachix.org` binary cache SHALL be removed, since packages now come from `cache.nixos.org`.

#### Scenario: no walker cachix substituter

- **WHEN** the nix configuration is evaluated
- **THEN** `walker.cachix.org` SHALL NOT be present as a substituter or trusted key
