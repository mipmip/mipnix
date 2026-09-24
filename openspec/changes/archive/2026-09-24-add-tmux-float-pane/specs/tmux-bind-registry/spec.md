## MODIFIED Requirements

### Requirement: prefix + ? opens the bindings menu

tmux SHALL bind `prefix + ?` to a `display-menu` built from the registry,
replacing tmux's default `list-keys` binding on that key. The menu SHALL show,
for every registered binding except those the registry marks as not belonging in
a menu, its key and its description.

A binding kept out of the menu SHALL still be bound and SHALL still appear in
the cheatsheets. Only its row is absent, because a menu row invites the reader
to fire it and some bindings do nothing outside a context the menu cannot show.

The menu SHALL be a `display-menu` rather than a popup, because a popup cannot
open another popup: from inside a `display-popup -E`, a further `display-popup`
exits 0 and does nothing, which would silently break every entry that launches a
popup tool.

#### Scenario: Opening the menu

- **WHEN** the user presses `prefix + ?` inside tmux
- **THEN** a menu opens listing every registered binding with its key and
  description, except those marked as not belonging in a menu

#### Scenario: A binding kept out of the menu

- **WHEN** a binding marked as not belonging in a menu is registered
- **THEN** the menu SHALL NOT contain a row for it
- **AND** pressing its key SHALL still run its command

#### Scenario: Launching a popup tool from the menu

- **WHEN** an entry whose command is a `display-popup` is fired from the menu
- **THEN** the menu closes and that popup opens
- **AND** the tool behaves exactly as it does when its key is pressed directly

#### Scenario: list-keys is no longer bound to the key

- **WHEN** `prefix + ?` is pressed
- **THEN** tmux's raw `list-keys` output SHALL NOT be shown

## ADDED Requirements

### Requirement: A key that cannot be rendered as a menu row is rejected

The menu row's name begins with the binding's key, and tmux renders a menu item
whose name begins with `-` as dim and unselectable. A binding on such a key
would therefore appear in the menu as a dead row that cannot be chosen, with
nothing to say why.

A registered binding whose key would produce such a row SHALL either be marked
as not belonging in the menu, or fail the build. It SHALL NOT be emitted as a
row the user cannot use.

#### Scenario: The `-` key registered for the menu

- **WHEN** a binding on the `-` key is registered without being marked out of
  the menu
- **THEN** the build SHALL fail with a message naming the entry

#### Scenario: The `-` key kept out of the menu

- **WHEN** a binding on the `-` key is registered and marked as not belonging in
  the menu
- **THEN** the build SHALL succeed
- **AND** the key SHALL be bound

#### Scenario: Ordinary keys are unaffected

- **WHEN** a binding on any key that does not begin a menu name with `-` is
  registered
- **THEN** it SHALL appear in the menu as before
