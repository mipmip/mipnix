## ADDED Requirements

### Requirement: A registered chord is emitted as a root-table binding

The tmux module SHALL emit a registered `chord` entry as a root-table binding
(`bind -n`), and a registered `prefixed` entry as a prefix-table binding
(`bind`), from the same registry and the same single declaration.

A root-table binding takes its key away from whatever is running in the pane,
so an entry that only means something in one context SHALL be guarded by the
action itself rather than by the emitter. The emitter SHALL carry the action
verbatim, as it does for every other entry.

#### Scenario: A chord reaches the root table

- **WHEN** a tmux entry of kind `chord` is registered
- **THEN** the generated configuration SHALL contain a `bind -n` line for that
  key running that action

#### Scenario: A prefixed entry is unchanged

- **WHEN** a tmux entry of kind `prefixed` is registered
- **THEN** the generated configuration SHALL contain a `bind` line without
  `-n`, exactly as before

#### Scenario: A guarded root binding falls through

- **WHEN** a root-table binding's action is conditional on some state and that
  state does not hold
- **THEN** the key SHALL reach the program running in the pane
- **AND** the program SHALL behave as though the key were not bound
