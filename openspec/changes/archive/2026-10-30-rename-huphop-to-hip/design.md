## Context

hip is huphop under a new name. Commands, flags, config schema and the
`switch_command` template context are unchanged; only the names are new.

## Goals / Non-Goals

**Goals:**

- Run hip with the same configuration and tmux wiring as before.

**Non-Goals:**

- Changing switcher behaviour or the config contents.
- Migrating `~/.cache/huphop`; hip rebuilds its own cache.

## Decisions

- **New capability instead of renaming the old one.** OpenSpec renames
  requirements but not capabilities, so the requirements are removed from
  `huphop-tmux-switcher` and added to `hip-tmux-switcher`. The change sets
  `retire_capabilities: true`, so archiving deletes the old spec.
- **Version prerequisites point at hip as a whole.** The old spec required
  huphop >= 1.1 and >= 1.4 for `clone_vcs` and `{{.Collection}}`. Every hip
  release has both, so the requirement now names hip without a version.

## Risks / Trade-offs

- A host that has not run `up_home` yet still has `hup`, whose config
  home-manager no longer provides there once it switches. Mitigation: hip
  arrives in the same switch that removes the old config.
