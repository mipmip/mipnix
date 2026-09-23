# jj-workflow-aliases Specification

## Purpose
TBD - created by archiving change add-jj-workflow-aliases. Update Purpose after archive.
## Requirements
### Requirement: Provide a jj `tug` alias to advance the closest bookmark
The jj configuration SHALL define an alias `tug` that moves the bookmark closest behind the
working copy up to `@-`, and SHALL define the `closest_bookmark` revset alias it depends on.

#### Scenario: Move bookmark before pushing
- **WHEN** the user runs `jj tug`
- **THEN** jj SHALL move the bookmark closest behind `@-` to point at `@-`

#### Scenario: On a main-only workflow
- **WHEN** `main` is the only bookmark and sits behind the working copy
- **THEN** `jj tug` SHALL move `main` to `@-`, equivalent to `jj bookmark set main -r @-`

#### Scenario: No bookmark behind the working copy
- **WHEN** there is no bookmark reachable behind `@-`
- **THEN** `jj tug` SHALL fail with jj's own error and SHALL NOT modify any bookmark

### Requirement: Provide a fish `jp` abbreviation to publish
The fish configuration SHALL define an abbreviation `jp` that expands to
`jj tug && jj git push`.

#### Scenario: Expand publish abbreviation
- **WHEN** the user types `jp` and accepts the abbreviation in an interactive fish shell
- **THEN** the command line SHALL expand to `jj tug && jj git push`

#### Scenario: Tug failure aborts push
- **WHEN** `jj tug` exits non-zero during `jp`
- **THEN** `jj git push` SHALL NOT run (guarded by `&&`)

### Requirement: Provide a fish `jc` abbreviation for commit
The fish configuration SHALL define an abbreviation `jc` that expands to `jj commit -m`,
using the built-in `jj commit` (describe `@` then create a new empty change on top) rather
than a hand-rolled `describe && new` chain.

#### Scenario: Expand commit abbreviation
- **WHEN** the user types `jc` and accepts the abbreviation in an interactive fish shell
- **THEN** the command line SHALL expand to `jj commit -m` with the cursor positioned to type the message

#### Scenario: Equivalence to describe-and-new
- **WHEN** the user runs `jc "some message"`
- **THEN** the effect SHALL be identical to `jj describe -m "some message" && jj new`

### Requirement: Do not duplicate the built-in commit motion
The configuration SHALL NOT define a separate alias or function that chains
`jj describe` and `jj new`, since `jj commit` already provides that behavior.

#### Scenario: No redundant describe+new alias exists
- **WHEN** the jj and fish configurations are inspected
- **THEN** there SHALL be no alias or function whose body chains `jj describe` with `jj new`

