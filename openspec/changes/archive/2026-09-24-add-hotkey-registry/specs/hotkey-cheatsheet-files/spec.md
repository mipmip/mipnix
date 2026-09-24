## Purpose

The files the two cheatsheet viewers read, keyb's hotkey file and myhotkeys'
`keys.json`, are generated from the hotkey registry, so that what is documented
is what is bound and neither file is written by hand.

## ADDED Requirements

### Requirement: The keyb hotkey file is generated from the registry

The keyb hotkey file SHALL be generated from the registry. Entries SHALL be
grouped into keyb sections by the application they belong to, and each keyb
keybind SHALL take its name from the entry's description and its key from the
rendered key.

#### Scenario: A section per application

- **WHEN** the registry holds entries for Hyprland, tmux and sc-im
- **THEN** the generated keyb file SHALL contain a section for each
- **AND** each section SHALL contain that application's entries

#### Scenario: The description becomes the keybind name

- **WHEN** an entry declares the description `Toggle floating`
- **THEN** the generated keyb keybind SHALL be named `Toggle floating`

#### Scenario: Section order is not relied upon

- **WHEN** the generated file is displayed by keyb
- **THEN** the configuration SHALL NOT depend on section order, since keyb sorts
  sections alphabetically regardless of the order in the file

### Requirement: The tmux prefix is shown without being frozen

tmux entries SHALL be documented so that the prefix is visible. The prefix SHALL
NOT be baked into the file as a fixed key combination, because the `tmxa` and
`tmxb` aliases switch the running prefix between `Ctrl+A` and `Ctrl+B`, which
would make a written prefix wrong half the time.

#### Scenario: A prefixed entry is readable

- **WHEN** a tmux entry bound to `S` is displayed
- **THEN** the reader SHALL be able to tell that the key is pressed after the
  prefix

#### Scenario: The prefix has been switched

- **WHEN** `tmxa` has switched the prefix to `Ctrl+A` and the cheatsheet is
  opened
- **THEN** the cheatsheet SHALL NOT claim a prefix that is not in effect

### Requirement: myhotkeys keys.json is generated from the registry

`~/.config/myhotkeys/keys.json` SHALL be generated from the registry in the
schema myhotkeys reads: a list of groups, each with a name and a list of
shortcuts carrying a description together with either a key or a command.

The checked-in `myhotkeys.json` SHALL be removed.

#### Scenario: A chord becomes a key shortcut

- **WHEN** a `chord` entry with modifiers `super` and `shift` and key `D` is
  rendered for myhotkeys
- **THEN** the generated shortcut SHALL carry the key `<SHIFT><SUPER>D` and the
  entry's description

#### Scenario: A word becomes a command shortcut

- **WHEN** a `word` entry with the text `gsb` is rendered for myhotkeys
- **THEN** the generated shortcut SHALL carry the command `gsb`, not a key

#### Scenario: The hand-maintained file is gone

- **WHEN** the repository is inspected after the change
- **THEN** no hand-written `myhotkeys.json` SHALL exist
- **AND** every entry that file lists today SHALL be present in the registry or
  deliberately dropped

#### Scenario: Bindings missing today are present after the change

- **WHEN** the generated `keys.json` is opened
- **THEN** it SHALL list the Hyprland bindings the hand-written file omits,
  among them the launcher on `Super+Space`, the quick settings on `Super+A`, the
  previous-workspace switch on `Super+Tab` and the screenshot reveal on
  `Ctrl+Shift+E`
- **AND** it SHALL list every custom tmux binding, not only the urlview one

### Requirement: Each viewer receives the entries its scope selects

The set of entries written to each generated file SHALL be determined by scope
tags, not by a second hand-kept list. A viewer's contents SHALL change when an
entry's scope changes, with no other edit.

#### Scenario: Retagging moves an entry between viewers

- **WHEN** an entry's scope is changed
- **THEN** the generated files SHALL reflect the new selection
- **AND** no file other than the entry itself SHALL have been edited

### Requirement: Per-context keyb files are generated

In addition to a full keyb file holding every in-scope entry, a keyb file SHALL
be generated for each application that has its own entries, holding only that
application's section.

This is what makes a context-aware viewer possible without keyb needing a filter
flag, since keyb accepts a hotkey file path.

#### Scenario: A per-application file

- **WHEN** the registry holds neovim entries
- **THEN** a keyb file containing only the neovim section SHALL be generated

#### Scenario: The full file

- **WHEN** the full keyb file is opened
- **THEN** it SHALL contain every entry in scope for the terminal viewer,
  including the sections that also have their own file

### Requirement: Sequence and multi-key entries are rendered literally

An entry of kind `sequence` SHALL be rendered as written, since it describes
keys pressed inside another application and has no modifier structure to
translate.

#### Scenario: An in-application sequence

- **WHEN** a `sequence` entry declares `y y` with the description `Yank cell`
- **THEN** the generated cheatsheet SHALL show `y y` with that description
- **AND** no modifier rendering SHALL be applied to it
