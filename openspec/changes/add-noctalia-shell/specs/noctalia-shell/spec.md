# Capability: noctalia-shell

Noctalia Shell integration as the primary Hyprland desktop shell.

## ADDED Requirements

### Requirement: Noctalia flake input available

The flake SHALL include the Noctalia Shell input following the project's nixpkgs.

#### Scenario: Flake includes noctalia input
- **Given** the flake.nix file
- **When** inputs are defined
- **Then** a `noctalia` input exists pointing to `github:noctalia-dev/noctalia-shell`
- **And** the input follows `nixpkgs` for consistency

---

### Requirement: Noctalia Home Manager module configured

A Home Manager module SHALL enable and configure Noctalia Shell for the pim user.

#### Scenario: Noctalia enabled via Home Manager
- **Given** the pim user's Home Manager configuration
- **When** the noctalia module is imported
- **Then** `programs.noctalia-shell.enable` is set to `true`
- **And** `programs.noctalia-shell.systemd.enable` is set to `true`

#### Scenario: Noctalia module follows naming convention
- **Given** the module at `modules/users/pim/programs/noctalia/default.nix`
- **When** registered in the flake
- **Then** it is accessible as `flake.modules.homeManager.pim-noctalia`

---

### Requirement: Noctalia IPC keybindings in Hyprland

Hyprland keybindings SHALL allow controlling Noctalia Shell functions.

#### Scenario: Launcher keybinding configured
- **Given** Hyprland binds.conf
- **When** a launcher keybinding is pressed
- **Then** `noctalia-shell ipc call launcher toggle` is executed

#### Scenario: Session menu keybinding configured
- **Given** Hyprland binds.conf
- **When** a session menu keybinding is pressed
- **Then** `noctalia-shell ipc call sessionMenu toggle` is executed

---

## MODIFIED Requirements

### Requirement: Hyprland autostart excludes replaced components

Components replaced by Noctalia SHALL be removed from autostart.

#### Scenario: ashell removed from autostart
- **Given** Hyprland autostart.conf
- **When** Noctalia is the primary shell
- **Then** ashell is not started (Noctalia systemd service handles startup)

---

## Related Capabilities

- `home-manager-config`: Module naming convention and registration
- `flake-structure`: Flake input patterns
