# Tmux Beans Popup

## MODIFIED Requirements

### Requirement: beans-tui-popup-keybind

A tmux keybinding `prefix + B` SHALL open a large `display-popup` that launches `beans tui` via a `beans-tui-popup` preflight script. On a clean quit the popup SHALL close; on failure it SHALL display the CWD in use and the `beans check` output and wait for a keypress (it SHALL NOT silently flash-close).

#### Scenario: opening the popup in a beans project

- **WHEN** the user presses `prefix + B` from a directory at or below a beans project (a `.beans.yml` exists at or above the pane's current directory)
- **THEN** a `display-popup` sized 90% × 90% SHALL open and run `beans tui` in that directory

#### Scenario: clean quit closes the popup

- **WHEN** the user quits `beans tui` normally (exit code 0)
- **THEN** the popup SHALL close automatically without requiring a keypress

#### Scenario: no beans project — verbose failure, hold open

- **WHEN** the user presses `prefix + B` from a directory with no `.beans.yml` at or above it
- **THEN** the popup SHALL display the current working directory and the `beans check` output, and SHALL wait for a keypress ("Press any key to close") before closing — rather than flash-closing

#### Scenario: beans tui exits non-zero — verbose failure, hold open

- **WHEN** `beans tui` exits with a non-zero status (e.g. it crashes)
- **THEN** the popup SHALL display the non-zero exit code, the current working directory, and the `beans check` output, and SHALL wait for a keypress before closing

#### Scenario: preflight does not rely on beans check exit code

- **WHEN** the preflight determines whether a beans project exists
- **THEN** it SHALL gate on the presence of `.beans.yml` (searched upward), NOT on the exit code of `beans check` (which returns 0 even when no project exists)
