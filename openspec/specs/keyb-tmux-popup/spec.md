# keyb-tmux-popup Specification

## Purpose
keyb, a terminal hotkey cheatsheet viewer that is not packaged in nixpkgs, is
built from source and opened from a tmux key in a popup that shows the sheet
matching whatever is running in the current pane.

## Requirements

### Requirement: keyb is packaged in this repository

keyb SHALL be built from its upstream source at a pinned tagged release, because
it is not available in nixpkgs. It SHALL be provided the way `clear-sans` is:
through an overlay in `modules/nix/overlays/`, registered in the channels
module, so that consuming modules refer to it as an ordinary package.

#### Scenario: The package is available

- **WHEN** a module adds keyb to `home.packages`
- **THEN** the build SHALL succeed
- **AND** running `keyb --version` SHALL report the pinned release

#### Scenario: The source is pinned

- **WHEN** the package definition is inspected
- **THEN** it SHALL reference a tagged upstream revision with a fixed hash
- **AND** it SHALL NOT track a moving branch

### Requirement: A tmux key opens keyb in a popup

A tmux key SHALL open keyb in a `display-popup`. The binding SHALL be declared
in the hotkey registry like every other tmux binding, so that it appears in the
`prefix + ?` menu alongside the rest.

#### Scenario: Opening the cheatsheet

- **WHEN** the user presses the bound key inside tmux
- **THEN** keyb SHALL open in a popup over the current pane
- **AND** it SHALL show the generated cheatsheet

#### Scenario: Closing the popup

- **WHEN** the user quits keyb
- **THEN** the popup SHALL close
- **AND** the pane underneath SHALL be unchanged

#### Scenario: The binding is listed with the others

- **WHEN** `prefix + ?` is opened
- **THEN** the keyb binding SHALL appear in the menu with its description

### Requirement: The popup shows the sheet for the current pane's program

The launcher SHALL inspect the command running in the pane the popup was opened
over and SHALL pass keyb the generated cheatsheet file for that program. This
uses keyb's ability to take a hotkey file path, so no upstream change and no
filter flag are needed.

#### Scenario: Opened over an editor

- **WHEN** the popup is opened from a pane running neovim
- **THEN** keyb SHALL open the neovim cheatsheet

#### Scenario: Opened over a shell

- **WHEN** the popup is opened from a pane running the shell
- **THEN** keyb SHALL open the full cheatsheet

#### Scenario: An unrecognised program

- **WHEN** the popup is opened from a pane running a program that has no
  cheatsheet of its own
- **THEN** keyb SHALL open the full cheatsheet
- **AND** the popup SHALL NOT fail or close immediately

### Requirement: The full cheatsheet is reachable regardless of context

The user SHALL be able to reach the full cheatsheet from within the popup or
through a second key, so that a context-aware default never hides an entry the
user is looking for.

#### Scenario: Escaping a narrow context

- **WHEN** the popup has opened a per-application sheet and the user wants the
  rest
- **THEN** the full cheatsheet SHALL be reachable without leaving tmux and
  reopening the popup elsewhere

### Requirement: keyb does not replace the actionable bindings menu

`prefix + ?` SHALL keep opening the `display-menu` that fires the highlighted
command. keyb SHALL be bound to a different key and SHALL remain a read-only
view, since keyb lists command selection as an explicit non-feature.

#### Scenario: The menu still executes

- **WHEN** the user opens `prefix + ?` and presses Enter on an entry
- **THEN** that entry's command SHALL run, as it does today

#### Scenario: The cheatsheet does not execute

- **WHEN** the user selects a line in keyb
- **THEN** nothing SHALL be executed
- **AND** the user SHALL be able to read the key and press it themselves

### Requirement: The popup is opened from a key, not from another popup

The keyb popup SHALL be opened by a key binding directly. It SHALL NOT be
reachable only from inside another `display-popup`, because a `display-popup`
invoked from within a `display-popup -E` exits successfully and does nothing,
which would make the entry fail silently.

#### Scenario: Launching from the bindings menu

- **WHEN** the keyb entry is fired from the `prefix + ?` menu
- **THEN** the popup SHALL open, because the menu is a `display-menu` and not a
  popup

#### Scenario: Not nested inside a popup

- **WHEN** the configuration is inspected
- **THEN** no path to the keyb popup SHALL require an enclosing
  `display-popup -E` to be open
