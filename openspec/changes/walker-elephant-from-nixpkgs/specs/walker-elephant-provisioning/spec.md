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

### Requirement: walker-via-home-manager-service

Walker SHALL be installed and run via the official home-manager `services.walker` module as a systemd user service.

#### Scenario: walker service enabled

- **WHEN** the home configuration is built and activated
- **THEN** `services.walker` SHALL be enabled with `systemd.enable = true`, providing a `walker` systemd user service that runs `walker --gapplication-service`

#### Scenario: redundant autostart removed

- **WHEN** the session starts
- **THEN** there SHALL NOT be a separate `exec-once = walker --gapplication-service` autostart entry (the systemd user service owns running walker)

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
