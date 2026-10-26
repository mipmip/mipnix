## ADDED Requirements

### Requirement: A tmux entry's kind decides which key table binds it

The registry SHALL distinguish, for the tmux target, a key pressed after the
prefix from a key pressed on its own. A `prefixed` entry SHALL bind in tmux's
prefix table, as every tmux entry does today. A `chord` entry SHALL bind in
tmux's root table, so that its key acts without the prefix.

No field SHALL be added for this. The kind already carries the distinction: a
`chord` is defined as an absolute key combination, and a key that acts without
a prefix is exactly that.

The two SHALL occupy separate key spaces for duplicate detection, because
`Escape` on its own and `prefix` followed by `Escape` are different bindings
and registering both SHALL be allowed.

#### Scenario: A prefixed tmux entry is unaffected

- **WHEN** a tmux entry declares kind `prefixed`
- **THEN** it SHALL bind after the prefix exactly as it does today
- **AND** its cheatsheet row SHALL show the prefix together with the key

#### Scenario: A tmux chord binds without the prefix

- **WHEN** a tmux entry declares kind `chord` with a key and no modifiers
- **THEN** its key SHALL act without the prefix being pressed first
- **AND** its cheatsheet row SHALL show the key alone, with no prefix label

#### Scenario: Both spellings of the same key coexist

- **WHEN** a tmux `chord` on `Escape` and a tmux `prefixed` entry on `Escape`
  are both registered
- **THEN** the build SHALL succeed
- **AND** neither SHALL be reported as a duplicate of the other

### Requirement: A tmux chord carrying a modifier is rejected

The registry holds no tmux spelling for a modifier, so a tmux `chord` that
declares one cannot be rendered. The build SHALL fail with a message naming the
entry, rather than emit a binding with the modifier silently dropped.

#### Scenario: A modifier on a tmux chord

- **WHEN** a tmux entry declares kind `chord` with a modifier
- **THEN** the build SHALL fail with a message naming that entry

#### Scenario: A modifier on a chord for another target

- **WHEN** a `chord` with a modifier is registered for a target that can spell
  modifiers
- **THEN** the build SHALL succeed, as before
