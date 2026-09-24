# hotkey-config-emission Specification

## Purpose
The configuration that actually binds a key is generated from the hotkey
registry for every application this repository configures, so that a binding
exists in exactly one place and the file the application reads is a derived
artefact.

## Requirements

### Requirement: Hyprland bindings are generated from the registry

`hypr/binds.conf` SHALL be generated from the registry entries targeting
Hyprland. The file SHALL NOT be maintained by hand.

The generator SHALL support the bind variants the current configuration uses:
the plain `bind`, the repeating and locked `bindel` used for volume and
brightness, and `bindm` for mouse bindings. An entry SHALL declare which variant
it needs, defaulting to `bind`.

The `$mainMod` indirection SHALL be preserved in the output rather than expanded
to `SUPER`, so the generated file reads like Hyprland configuration.

#### Scenario: A generated bind line

- **WHEN** an entry targets Hyprland with modifiers `super`, key `Q` and action
  `killactive,`
- **THEN** the generated file SHALL contain `bind = $mainMod, Q, killactive,`

#### Scenario: A repeating binding

- **WHEN** an entry declares the `bindel` variant
- **THEN** the generated line SHALL use `bindel` rather than `bind`
- **AND** the key SHALL repeat while held, as it does today

#### Scenario: Every existing binding survives the move

- **WHEN** the generated file is compared with the current hand-written
  `binds.conf`
- **THEN** every binding present today SHALL be present in the generated file
- **AND** each SHALL bind the same key to the same dispatcher and arguments

### Requirement: Explanatory comments reach the generated Hyprland file

An entry SHALL be able to carry a note, and the generator SHALL emit that note
as a comment above the generated line. The reasoning currently written in
`binds.conf`, such as why the lock binding resolves to hyprlock directly and why
the suspend binding does not lock first, SHALL still be readable in the
generated file.

#### Scenario: A note becomes a comment

- **WHEN** an entry carries a note
- **THEN** the generated file SHALL contain that note as a comment immediately
  above the entry's bind line

#### Scenario: Reasoning is not lost in the move

- **WHEN** the generated file is read while debugging Hyprland
- **THEN** the explanations that the hand-written file carries today SHALL be
  present

### Requirement: tmux bindings come from the registry

The tmux module SHALL take its custom bindings from the registry, filtered to
the tmux target, instead of holding its own list. What the tmux module does with
those entries is unchanged and is specified by `tmux-bind-registry`.

#### Scenario: The module holds no list

- **WHEN** the tmux module is inspected
- **THEN** it SHALL contain no list of bindings
- **AND** it SHALL derive its bindings from the registry

### Requirement: Shell aliases and abbreviations are generated from word entries

The `word` entries targeting the shell SHALL generate the fish aliases and
abbreviations. Each SHALL carry a description, which today's `shared.shellAliases`
attribute set has no room for.

An alias defined outside this repository, such as a `g*` abbreviation from a
plugin, SHALL be representable as a documentation-only `word` entry so that it
can be listed without this repository claiming to define it.

#### Scenario: An alias with a description

- **WHEN** a `word` entry declares the text `crb_mount`, its command, and a
  description
- **THEN** fish SHALL have that alias with the same command as today
- **AND** the description SHALL be available to the cheatsheets

#### Scenario: Every current alias still works

- **WHEN** the shell is started after the change
- **THEN** every alias defined today SHALL resolve to the same command

#### Scenario: A foreign abbreviation is documented, not defined

- **WHEN** a `word` entry for a plugin-provided abbreviation is declared with no
  target
- **THEN** it SHALL appear in the cheatsheets
- **AND** no fish alias or abbreviation SHALL be created for it

### Requirement: ghostty keybindings are generated from the registry

The ghostty `keybind` list SHALL be generated from the registry entries
targeting ghostty, rendered in ghostty's own key spelling.

#### Scenario: A generated ghostty keybind

- **WHEN** an entry targets ghostty with modifiers `ctrl` and `shift`, key `c`,
  and the action `copy_to_clipboard`
- **THEN** the generated configuration SHALL contain
  `ctrl+shift+c=copy_to_clipboard`

### Requirement: gnome keybindings are generated from the registry

The gnome keybinding `dconf` settings SHALL be generated from the registry
entries targeting gnome. A gnome entry's action SHALL be the dconf key it binds,
and the rendered value SHALL be the GTK accelerator list gnome expects.

An entry that deliberately unbinds a gnome default SHALL be expressible, since
the current configuration sets several keys to an empty list.

#### Scenario: A bound gnome action

- **WHEN** an entry targets gnome with the action `toggle-fullscreen`, modifier
  `super` and key `f`
- **THEN** the generated dconf settings SHALL bind `toggle-fullscreen` to
  `[ "<Super>f" ]`

#### Scenario: A deliberately unbound gnome action

- **WHEN** an entry declares that a gnome action is to be left unbound
- **THEN** the generated dconf settings SHALL set that action to an empty list
- **AND** the cheatsheets SHALL NOT list it

### Requirement: neovim keymaps are projected, not re-authored

The neovim keymaps SHALL keep their current form and location. They already
carry a key, a mode and a description, so the registry SHALL derive `mapped`
entries from them rather than require them to be written a second time.

Editing a keymap SHALL remain a single edit in the neovim configuration.

#### Scenario: A keymap reaches the cheatsheets untouched

- **WHEN** a neovim keymap declares a key, a mode and a description
- **THEN** a corresponding registry entry SHALL exist
- **AND** the neovim configuration SHALL NOT have been modified to make that
  happen

#### Scenario: A keymap with no description

- **WHEN** a neovim keymap carries no description
- **THEN** it SHALL be omitted from the registry rather than listed without one
- **AND** the build SHALL NOT fail

#### Scenario: Changing a keymap changes the cheatsheet

- **WHEN** a keymap's key or description is edited
- **THEN** the cheatsheets SHALL reflect the edit with no second change

### Requirement: The switch to generated output is verifiable

For every target whose configuration file is replaced by generated output, the
generated result SHALL be comparable against the file it replaces, so that the
move can be shown to change nothing.

#### Scenario: Comparing before and after

- **WHEN** the generated configuration for a target is compared with the
  hand-written file it replaces
- **THEN** the difference SHALL consist only of ordering, whitespace and
  comment placement
- **AND** no binding SHALL be added, removed or changed by the move alone

### Requirement: A target with no entries produces valid configuration

A target that has no registry entries SHALL produce an empty but valid
configuration for that target, and SHALL NOT fail the build.

#### Scenario: An empty target

- **WHEN** every entry for a target is removed
- **THEN** the generated configuration for it SHALL be empty and valid
- **AND** the application SHALL start with its own defaults
