# rme-shell-completions Specification

## Purpose
TBD - created by archiving change add-rme-shell-completions. Update Purpose after archive.

## Requirements

### Requirement: Fish completions for rme
The home-manager config SHALL provide a fish completion file at
`~/.config/fish/completions/rme.fish` whose body is the dynamic completion
`complete -c rme -f -a '(rme --completions)'`.

#### Scenario: Completion file is installed on switch
- **WHEN** the user runs `home-manager switch`
- **THEN** `~/.config/fish/completions/rme.fish` SHALL exist with the dynamic `complete` line

#### Scenario: Tab-completing rme in a RUNME.sh directory
- **WHEN** the user types `rme ` and presses Tab in fish inside a directory containing a `RUNME.sh`
- **THEN** fish SHALL offer the commands returned by `rme --completions`

#### Scenario: No shell restart required
- **WHEN** the completion file is added while a fish session is already open
- **THEN** that session SHALL pick up the completions on the next Tab of `rme` without restarting

### Requirement: Zsh completions for rme
The home-manager config SHALL wire zsh completion for `rme` via
`programs.zsh.initContent`, defining `_rme() { compadd $(rme --completions) }` and registering
it with `compdef _rme rme`.

#### Scenario: Completion active in a new zsh session
- **WHEN** the user opens a new zsh session after `home-manager switch` and tab-completes `rme `
  in a directory containing a `RUNME.sh`
- **THEN** zsh SHALL offer the commands returned by `rme --completions`

### Requirement: Completions are dynamic, not a baked list
The completion wiring SHALL invoke `rme --completions` at completion time and SHALL NOT embed a
static list of commands.

#### Scenario: Suggestions reflect the current directory
- **WHEN** the user tab-completes `rme` in two different directories with different `RUNME.sh` files
- **THEN** each directory SHALL offer that directory's own commands

#### Scenario: Directory without a RUNME.sh
- **WHEN** the user tab-completes `rme` in a directory with no `RUNME.sh`
- **THEN** no command suggestions SHALL be offered and no error SHALL be shown

### Requirement: Declarative wiring only
The configuration SHALL NOT rely on `rme completion install` or any imperative runtime
installation step.

#### Scenario: No imperative install is used
- **WHEN** the fish and zsh completion wiring is inspected
- **THEN** it SHALL be provided through home-manager options and SHALL NOT invoke `rme completion install`
