# hotkey-registry Specification

## Purpose
A single flake-wide registry that holds every keybinding, shell word and
cheatsheet reminder once, so that the configuration that binds a key and the
cheatsheet that documents it are derived from the same declaration and cannot
disagree.

## Requirements

### Requirement: One registry, contributed from any module

The flake SHALL expose a merged hotkey registry that any module may append to,
in the same way `flake.nebulaNodes` is contributed per host. No module SHALL
hold a second list of bindings of its own.

A consumer SHALL read the merged registry and filter it, rather than receive a
list assembled for it.

#### Scenario: Two modules contribute

- **WHEN** the Hyprland module and the tmux module each add entries to the
  registry
- **THEN** both sets of entries SHALL be present in the merged registry
- **AND** neither module SHALL have to know about the other

#### Scenario: An entry is added in one place only

- **WHEN** a new binding is added to the registry
- **THEN** it SHALL reach every consumer that its target and scope select
- **AND** no other file SHALL need editing for it to appear

#### Scenario: A duplicate binding is rejected

- **WHEN** two entries declare the same key on the same target, for example two
  Hyprland entries both on `Super+W`
- **THEN** the build SHALL fail with a message naming both entries
- **AND** no configuration SHALL be generated

### Requirement: An entry declares one of five kinds

A registry entry SHALL declare its kind, because the things worth remembering do
not share one shape. The kinds SHALL be:

- `chord`: an absolute modifier combination, as Hyprland, gnome and ghostty use
- `prefixed`: a key pressed after a leading key, as tmux uses
- `mapped`: an editor mode together with a left-hand side, as neovim uses
- `word`: something typed rather than pressed, such as a shell alias or
  abbreviation
- `sequence`: an in-application multi-key run that this configuration does not
  bind, such as `y y` in sc-im

Each kind SHALL carry a description. A kind that can be emitted SHALL also carry
its target and its action.

#### Scenario: A chord entry

- **WHEN** an entry declares kind `chord` with modifiers and a key
- **THEN** it SHALL be renderable as an absolute key combination for every
  target that accepts one

#### Scenario: A prefixed entry

- **WHEN** an entry declares kind `prefixed`
- **THEN** its key SHALL be interpreted relative to the target's prefix
- **AND** the rendered documentation SHALL show the prefix together with the key

#### Scenario: A word entry

- **WHEN** an entry declares kind `word` with the text `gsb` and a description
- **THEN** it SHALL be emittable as a shell alias or abbreviation
- **AND** it SHALL be documented as something typed, not as a key combination

#### Scenario: A sequence entry binds nothing

- **WHEN** an entry declares kind `sequence`
- **THEN** it SHALL appear in the cheatsheets
- **AND** it SHALL NOT be written into any application's configuration

#### Scenario: An entry without a description is rejected

- **WHEN** an entry of any kind is declared with no description
- **THEN** the build SHALL fail

### Requirement: Keys are canonical and rendered per target

A `chord` entry SHALL name its key using X11 keysym names and its modifiers from
a fixed set. The registry SHALL NOT store a target's own spelling. Each consumer
SHALL render the canonical form into its target's syntax.

A target whose spelling differs from the keysym name, as ghostty's `enter` does
from `Return`, SHALL be served by a per-target alias table rather than by a
second spelling in the entry.

#### Scenario: One declaration, five spellings

- **WHEN** an entry declares modifiers `super` and `shift` with key `Return`
- **THEN** the Hyprland output SHALL read `$mainMod SHIFT, RETURN`
- **AND** the gnome and myhotkeys output SHALL read `<Shift><Super>Return`
- **AND** the ghostty output SHALL read `super+shift+enter`
- **AND** the keyb output SHALL read a human-readable combination naming Super,
  Shift and Return

#### Scenario: An unknown keysym is rejected

- **WHEN** an entry names a key that is not a known keysym, for example `Enter`
  instead of `Return`
- **THEN** the build SHALL fail with a message naming the entry and the
  unrecognised key

#### Scenario: A modifier a target cannot express

- **WHEN** an entry uses a modifier that its target has no spelling for
- **THEN** the build SHALL fail rather than emit a binding that the target would
  silently ignore

### Requirement: The action stays in target-native syntax

An entry's action SHALL be carried verbatim and SHALL NOT be canonicalised,
because a Hyprland dispatcher, a tmux command and a neovim callback share no
common form. Only the key is translated.

#### Scenario: Native actions pass through unchanged

- **WHEN** a Hyprland entry declares the action `exec, walker` and a tmux entry
  declares `popup -E smg`
- **THEN** each SHALL appear in its target's configuration exactly as written
- **AND** neither SHALL be rewritten or escaped beyond what its target's syntax
  requires

### Requirement: An entry names the target that owns it

An entry SHALL name the target responsible for binding it, or declare that no
target owns it. Only an owned entry SHALL be emitted into a configuration file.
An unowned entry SHALL be documentation only.

#### Scenario: A documented foreign binding

- **WHEN** an entry documents a binding of an application this repository does
  not configure, such as `Tab` in zathura or `Ctrl+K` in firefox
- **THEN** it SHALL appear in the cheatsheets
- **AND** no configuration file SHALL be generated or modified because of it

#### Scenario: An owned entry reaches its target

- **WHEN** an entry names the Hyprland target
- **THEN** the generated Hyprland configuration SHALL contain a binding for it
- **AND** no other target's configuration SHALL contain it

### Requirement: Entries carry scope tags that select their audience

An entry SHALL carry one or more scope tags. A consumer SHALL select entries by
scope, so that a viewer can show a subset without a second list existing
anywhere.

#### Scenario: A viewer receives a subset

- **WHEN** a consumer asks for the entries tagged as belonging to the terminal
- **THEN** it SHALL receive the tmux, neovim, shell and terminal-application
  entries
- **AND** it SHALL NOT receive the desktop window-management entries

#### Scenario: An entry with no scope tag

- **WHEN** an entry declares no scope
- **THEN** it SHALL be treated as belonging to every scope
- **AND** it SHALL appear in every viewer

### Requirement: The registry is plain data, evaluable without a package set

The registry SHALL hold strings, lists and attribute sets only, and SHALL be
evaluable without a package set. A value that requires a store path SHALL NOT be
placed in the registry; the consuming module SHALL resolve it.

This keeps the registry readable from the flake level, where `pkgs` is not yet
available, so that every consumer can reach it regardless of whether it is a
NixOS module, a home-manager module or a neovim configuration.

#### Scenario: A consumer outside home-manager reads the registry

- **WHEN** a consumer that has no `pkgs` in scope reads the registry
- **THEN** it SHALL evaluate successfully
- **AND** it SHALL see every contributed entry

### Requirement: Validation rejects values a target cannot render

The registry SHALL fail the build, rather than emit broken output, when an entry
holds a value its target cannot represent. The rules the tmux module enforces
today SHALL be preserved and applied at registry level: a description SHALL NOT
begin with `-`, a description SHALL NOT contain an apostrophe, and a key or
command containing `;` SHALL be escaped for tmux.

A failure SHALL name the offending entry, so that the entry can be found without
reading the generator.

#### Scenario: A description beginning with a dash

- **WHEN** an entry bound on the tmux target has a description starting with `-`
- **THEN** the build SHALL fail with a message naming that entry

#### Scenario: A description containing an apostrophe

- **WHEN** an entry bound on the tmux target has a description containing `'`
- **THEN** the build SHALL fail with a message naming that entry

#### Scenario: A validation rule applies only to the target that needs it

- **WHEN** an entry with an apostrophe in its description is bound on a target
  that renders it safely
- **THEN** the build SHALL succeed
- **AND** the description SHALL appear unmodified

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
