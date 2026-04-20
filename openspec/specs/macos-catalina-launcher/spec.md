# macos-catalina-launcher Specification

## Purpose
TBD - created by archiving change add-macos-catalina-launcher. Update Purpose after archive.
## Requirements
### Requirement: Desktop launcher for macOS Catalina VM
The system SHALL provide a `.desktop` entry named "macOS Catalina" that appears in the GNOME application grid for user annemarie on lavendel.

#### Scenario: Launcher visible in app grid
- **WHEN** annemarie opens the GNOME application grid on lavendel
- **THEN** a "macOS Catalina" entry with a macOS icon is visible

#### Scenario: Launcher starts VM
- **WHEN** annemarie clicks the "macOS Catalina" launcher
- **THEN** the system runs `setup-network.sh` followed by `macos-catalina.sh` from `/home/annemarie/macos-catalina/` with CWD set to `/home/annemarie`

### Requirement: Wrapper script managed by home-manager
The system SHALL deploy a wrapper script to annemarie's home directory via `home.file` that sequences the two VM scripts.

#### Scenario: Script runs in correct order
- **WHEN** the wrapper script executes
- **THEN** it first runs `setup-network.sh`, and only after it completes, runs `macos-catalina.sh`

#### Scenario: Script sets correct working directory
- **WHEN** the wrapper script executes
- **THEN** the working directory is `/home/annemarie` before running either script

### Requirement: macOS icon deployed via home-manager
The system SHALL deploy a macOS icon file to `~/.local/share/icons/` via `home.file` for use by the desktop entry.

#### Scenario: Icon file present after home-manager switch
- **WHEN** home-manager switch completes for annemarie on lavendel
- **THEN** the icon file exists at `~/.local/share/icons/macos-catalina.png`

### Requirement: Fix annemarie@lavendel home-manager configuration
The `annemarie@lavendel` makeHomeConf call SHALL specify `username = "annemarie"` and `homedir = "/home/annemarie"`.

#### Scenario: Correct user parameters
- **WHEN** home-manager builds for `annemarie@lavendel`
- **THEN** `home.username` is `"annemarie"` and `home.homeDirectory` is `"/home/annemarie"`

