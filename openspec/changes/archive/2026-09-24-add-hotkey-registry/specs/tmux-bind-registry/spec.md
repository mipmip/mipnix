## MODIFIED Requirements

### Requirement: Custom tmux bindings are declared once in a registry

The tmux home-manager module SHALL take its custom key bindings from the
flake-wide hotkey registry, filtered to the tmux target. The module SHALL NOT
hold a list of bindings of its own.

Each entry SHALL carry the key, a human-readable description, the tmux command
to run, and the group it belongs to. From that single declaration the module
SHALL emit both the `bind` line that binds the key and the entry that appears in
the help menu, so the two cannot disagree.

The tmux target SHALL cover only the bindings this configuration declares. tmux
defaults, bindings from `tmux-sensible`, the tmux defaults that the gpakosz
`_apply_bindings` pass rewrites in place, and bindings a tmux plugin makes for
itself SHALL NOT appear in it.

#### Scenario: One declaration, two emissions

- **WHEN** a binding is registered with a key, description and command
- **THEN** the generated tmux configuration SHALL contain a `bind` line for that
  key running that command
- **AND** the help menu SHALL contain an entry for that key showing that
  description and running the same command string

#### Scenario: Adding a binding requires no second edit

- **WHEN** a new binding is added to the registry
- **THEN** it SHALL appear in the help menu without any further change
- **AND** no list of bindings SHALL exist anywhere else in the module

#### Scenario: A binding added elsewhere reaches tmux

- **WHEN** a module other than the tmux module contributes an entry targeting
  tmux
- **THEN** that binding SHALL be bound and SHALL appear in the help menu
- **AND** the tmux module SHALL NOT have been edited

#### Scenario: The same declaration reaches the cheatsheets

- **WHEN** a tmux binding is registered
- **THEN** it SHALL also appear in the generated cheatsheet files
- **AND** no tmux binding SHALL be described a second time anywhere

#### Scenario: Foreign bindings are not listed

- **WHEN** the help menu is opened
- **THEN** it SHALL show only registered bindings
- **AND** tmux's own default bindings and the gpakosz-rewritten defaults SHALL
  NOT be listed

#### Scenario: A binding owned by a plugin

- **WHEN** a key is bound by a tmux plugin rather than by this configuration,
  as `u` is by the urlview plugin
- **THEN** it SHALL NOT be registered
- **AND** the plugin SHALL keep binding that key exactly as before

### Requirement: Registered bindings keep their current behaviour

Moving the existing bindings out of the module-local list and into the
flake-wide registry SHALL NOT change what any key does. Each key SHALL stay
bound to the command it is bound to today.

#### Scenario: Every existing key is unchanged

- **WHEN** any of the existing custom keys is pressed after the change
- **THEN** it SHALL run the same tmux command as before
- **AND** the launcher scripts it invokes SHALL be unmodified

#### Scenario: Launcher scripts are untouched

- **WHEN** the module is inspected after the change
- **THEN** `beans-tui-popup`, `nebula-ssh` and `drs-switch` SHALL be unchanged

#### Scenario: The menu is unchanged

- **WHEN** `prefix + ?` is opened after the change
- **THEN** the same bindings SHALL be listed, in the same groups, with the same
  separator and the same accelerators as before, plus the new cheatsheet entry
