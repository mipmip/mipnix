# tmux-bind-registry Specification

## Purpose
TBD - created by archiving change add-tmux-bind-registry. Update Purpose after archive.

## Requirements

### Requirement: Custom tmux bindings are declared once in a registry

The tmux home-manager module SHALL expose a registry of custom key bindings.
Each entry SHALL carry the key, a human-readable description, the tmux command
to run, and the group it belongs to. From that single declaration the module
SHALL emit both the `bind` line that binds the key and the entry that appears in
the help menu, so the two cannot disagree.

The registry SHALL cover only the bindings this configuration declares. tmux
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

### Requirement: prefix + ? opens the bindings menu

tmux SHALL bind `prefix + ?` to a `display-menu` built from the registry,
replacing tmux's default `list-keys` binding on that key. The menu SHALL show,
for every registered binding, its key and its description.

The menu SHALL be a `display-menu` rather than a popup, because a popup cannot
open another popup: from inside a `display-popup -E`, a further `display-popup`
exits 0 and does nothing, which would silently break every entry that launches a
popup tool.

#### Scenario: Opening the menu

- **WHEN** the user presses `prefix + ?` inside tmux
- **THEN** a menu opens listing every registered binding with its key and
  description

#### Scenario: Launching a popup tool from the menu

- **WHEN** an entry whose command is a `display-popup` is fired from the menu
- **THEN** the menu closes and that popup opens
- **AND** the tool behaves exactly as it does when its key is pressed directly

#### Scenario: list-keys is no longer bound to the key

- **WHEN** `prefix + ?` is pressed
- **THEN** tmux's raw `list-keys` output SHALL NOT be shown

### Requirement: The menu is navigable and dismissable

The menu SHALL support moving the selection with the arrow keys, firing the
highlighted entry with `Enter`, and closing without firing anything with
`Escape`. Every entry SHALL also be directly fireable by its own accelerator
key.

#### Scenario: Navigate and execute

- **WHEN** the user moves the selection with the arrow keys and presses `Enter`
- **THEN** the menu closes and the highlighted entry's command runs

#### Scenario: Dismiss without acting

- **WHEN** the user presses `Escape`
- **THEN** the menu closes
- **AND** no command runs

#### Scenario: Selection wraps

- **WHEN** the selection is on the first entry and the user presses Up
- **THEN** the selection moves to the last entry

### Requirement: An entry's accelerator is the key it is bound to

Each menu entry SHALL use its own binding key as its menu accelerator, so
pressing that key inside the menu performs the same action as pressing
`prefix + <key>` outside it.

#### Scenario: The key works inside the menu

- **WHEN** the menu is open and the user presses the key of a registered
  binding, for example `S`
- **THEN** that binding's command runs
- **AND** the effect is the same as pressing `prefix + S` with the menu closed

#### Scenario: Case is respected

- **WHEN** both an upper-case and a lower-case binding of the same letter are
  registered, for example `S` and `s`
- **THEN** each accelerator SHALL fire its own entry

### Requirement: Entries are grouped by kind

The registry SHALL group entries, and the menu SHALL render a separator between
groups. Bindings that launch a tool SHALL form one group, and bindings that act
on tmux itself SHALL form another.

#### Scenario: Groups are visually separated

- **WHEN** the menu is opened
- **THEN** the tool bindings SHALL be listed together
- **AND** a separator line SHALL divide them from the tmux bindings

### Requirement: Registered bindings keep their current behaviour

Moving the existing bindings into the registry SHALL NOT change what any key
does. Each key SHALL stay bound to the command it is bound to today.

#### Scenario: Every existing key is unchanged

- **WHEN** any of the existing custom keys is pressed after the change
- **THEN** it SHALL run the same tmux command as before
- **AND** the launcher scripts it invokes SHALL be unmodified

#### Scenario: Launcher scripts are untouched

- **WHEN** the module is inspected after the change
- **THEN** `beans-tui-popup`, `nebula-ssh` and `drs-switch` SHALL be unchanged

### Requirement: Registry values that would corrupt tmux command syntax are handled

The generated `bind` lines and menu entries SHALL remain valid tmux commands for
every registered entry. A key or command containing `;` SHALL be escaped, since
tmux parses an unescaped `;` as a command separator. A description SHALL NOT
begin with `-`, since tmux parses such a menu name as a flag and also uses a
leading `-` to mark an entry unselectable, and SHALL NOT contain an apostrophe,
which closes the single-quoted menu name early and swallows the entries after
it. Both SHALL fail the build rather than produce a truncated menu.

#### Scenario: A binding on the `;` key

- **WHEN** the `;` binding is registered
- **THEN** its `bind` line and its menu entry SHALL both be accepted by tmux
- **AND** firing it from the menu SHALL perform the last-pane action

#### Scenario: A description beginning with a dash is rejected

- **WHEN** an entry is registered whose description starts with `-`
- **THEN** the build SHALL fail with a message naming the offending entry

#### Scenario: A description containing an apostrophe is rejected

- **WHEN** an entry is registered whose description contains `'`
- **THEN** the build SHALL fail with a message naming the offending entry

### Requirement: No context-sensitive dimming

Menu entries SHALL always be selectable. The menu SHALL NOT attempt to grey out
an entry based on whether its tool has a valid context, because such conditions
are filesystem questions that a menu can only answer through tmux's `#()` shell
substitution, which is evaluated asynchronously and cached and therefore gives a
different answer on a second opening of the same menu.

Reporting an unusable context SHALL remain the launcher's responsibility, as
`beans-tui-popup` already does by printing the working directory and
`beans check` output and waiting for a keypress.

#### Scenario: An entry whose tool has no valid context

- **WHEN** the beans entry is fired from a directory with no beans project
- **THEN** the entry SHALL have been selectable
- **AND** the launcher SHALL report the missing project itself rather than the
  menu hiding the entry
