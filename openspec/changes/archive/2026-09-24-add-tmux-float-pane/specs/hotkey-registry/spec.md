## ADDED Requirements

### Requirement: An entry can be kept out of its target's menu

An entry SHALL be able to declare that it does not belong in the menu a target
generates from the registry, while still being bound and still reaching the
cheatsheets. The default SHALL be to appear, so an entry that says nothing about
it behaves as every entry does today.

This exists for bindings that only mean something in a context the menu cannot
represent. A flat list of every binding invites the reader to fire any of them,
and an entry that does nothing unless some other state holds is noise at best
and a broken-looking row at worst.

#### Scenario: An entry marked out of the menu

- **WHEN** an entry declares that it is not for the menu
- **THEN** its key SHALL still be bound
- **AND** it SHALL still appear in the generated cheatsheets
- **AND** it SHALL NOT appear in the menu

#### Scenario: The default is unchanged

- **WHEN** an entry says nothing about the menu
- **THEN** it SHALL appear in the menu, as before

#### Scenario: Independent of documentation

- **WHEN** an entry is kept out of the menu
- **THEN** whether it appears in the cheatsheets SHALL still be decided only by
  whether it is documented
