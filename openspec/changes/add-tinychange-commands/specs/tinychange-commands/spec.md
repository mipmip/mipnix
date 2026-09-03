## ADDED Requirements

### Requirement: tinychange-explore command
The config SHALL provide a `/mip:tinychange-explore` Claude Code command that starts a lightweight
exploration for a small change and produces a `tinychange`-schema change with a spec delta and tasks.

#### Scenario: Schema already present
- **WHEN** the command runs in a project where the `tinychange` schema resolves
- **THEN** it SHALL NOT reinstall the schema and SHALL proceed to explore

#### Scenario: Schema absent
- **WHEN** the command runs where `tinychange` does not resolve
- **THEN** it SHALL install the schema by following the `AGENT_INSTALL.md` from
  `speclib/openspec-tinychange-schema`, then validate it with `openspec schema validate tinychange`

#### Scenario: Full spec scan before delta
- **WHEN** exploring the change
- **THEN** it SHALL review the existing specs and, if the change affects behavior, produce a spec
  delta; if it does not, it SHALL set `skip_specs: true` on the change

#### Scenario: Lean artifacts only
- **WHEN** the change is created
- **THEN** it SHALL use `openspec new change <name> --schema tinychange`, producing only `specs` and
  `tasks` artifacts (no proposal or design)

### Requirement: tinychange-apply command
The config SHALL provide a `/mip:tinychange-apply` command that implements a tinychange change from its
tasks and archives it.

#### Scenario: Implement and archive
- **WHEN** the command runs for a tinychange change
- **THEN** it SHALL implement the change from `tasks.md`, mark tasks complete, and run
  `openspec archive` to sync the delta into the main specs

#### Scenario: Commit per convention
- **WHEN** archiving completes
- **THEN** it SHALL commit as Pim Snel with no self-promoting trailers and SHALL NOT push

### Requirement: Schema is not shipped by home-manager
home-manager SHALL provide only the two commands; it SHALL NOT install or package the `tinychange`
schema. The schema SHALL be installed on demand by the command from the public repo.

#### Scenario: Home-manager provides commands only
- **WHEN** the home-manager configuration is applied
- **THEN** the two `/mip:tinychange-*` commands SHALL be available and no `tinychange` schema files
  SHALL be installed by home-manager itself
