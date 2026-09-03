## ADDED Requirements

### Requirement: Collection-aware multiplex session naming
The multiplex `switch_command` SHALL name the tmux session after the active huphop collection when
one is active, and SHALL fall back to the existing `{{.Short}}->{{.OwnerLower}}` naming otherwise.
This requires the huphop input at a version that exposes `{{.Collection}}` in the `switch_command`
template context (huphop ≥ 1.4).

#### Scenario: Inside a collection
- **WHEN** the user switches to a repo while a collection is active
- **THEN** the target tmux session SHALL be named after that collection (creating it if absent),
  with a window per repository

#### Scenario: Outside a collection
- **WHEN** the user switches to a repo with no active collection (flat view or owner drill-down)
- **THEN** the target tmux session SHALL be named `<short>-><ownerLower>` exactly as before

#### Scenario: huphop version prerequisite
- **WHEN** the config is materialised
- **THEN** the huphop package SHALL be a version whose `switch_command` template context includes
  `Collection`, so the `{{if .Collection}}…{{end}}` template evaluates without error

### Requirement: Session/window names remain target-safe
The `hup-tmux-switch` wrapper SHALL accept the resolved session name as its first argument and
SHALL sanitize `:` and `.` out of session and window names so they cannot corrupt tmux's
`session:window.pane` target grammar.

#### Scenario: Collection name with a dot or colon
- **WHEN** a collection name contains `.` or `:`
- **THEN** the wrapper SHALL replace those characters before using the name as a tmux target,
  so the switch does not fail

#### Scenario: Existing sessions unchanged
- **WHEN** switching outside a collection
- **THEN** the sanitized session name SHALL equal the current `<short>-><ownerLower>` value, so
  no existing session behavior changes
