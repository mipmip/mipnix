## Context

OpenSpec 1.10 resolves schemas from exactly two places — project-local `openspec/schemas/<name>/`
and the package's bundled schemas — with **no global/personal schema dir** (verified: a schema
dropped in `~/.config/openspec/schemas/` is not seen). There is also **no `openspec install <url>`**
command; the community/promoted route (per the openspec-schemas repo) is: an agent reads an
`AGENT_INSTALL.md` and copies the schema files into the project, then `openspec schema validate`.

A spike validated the tinychange mechanics end-to-end:
- `openspec schema init tinychange --artifacts specs,tasks` → valid schema, artifacts `specs`+`tasks`.
- `openspec new change X --schema tinychange` → scaffolds only `specs`+`tasks`; `applyRequires: [tasks]`;
  no proposal/design.
- delta `validate --strict` ✓; `archive` syncs the delta into `openspec/specs/`; `skip_specs: true`
  lets a no-delta refactor validate.

## Decisions

### Decision 1: A `specs → tasks` schema, keep tasks
tinychange drops `proposal` and `design` but keeps `tasks` (the user values the checklist). Generated
by `openspec schema init tinychange --artifacts specs,tasks`. Full spec rigor is retained — the delta
still validates and archives exactly like spec-driven.

### Decision 2: Schema distributed via a public repo + AGENT_INSTALL, not nix
No flake / HM packaging of the schema. `speclib/openspec-tinychange-schema` holds
`openspec/schemas/tinychange/` (schema.yaml + templates), a self-documenting `README.md`, and an
`AGENT_INSTALL.md` the cc-command executes. This follows OpenSpec's own promoted route and keeps the
schema reproducible for collaborators via a URL rather than a nix-only install.

### Decision 3: The command self-heals the schema (check → install → run)
`/mip:tinychange-explore` first checks presence (`openspec schema which tinychange`, or
`openspec/schemas/tinychange/` exists). If absent, it fetches the repo's `AGENT_INSTALL.md` and follows
it (copy files, `openspec schema validate tinychange`). Only then does it create the change. So HM
ships just the commands; the schema arrives on first use per project.

### Decision 4: Two commands, explore owns install
- `explore`: presence/install + lightweight think + FULL existing-spec scan + `new change --schema
  tinychange` + write delta (or `skip_specs: true`) + `tasks.md`. Stops there.
- `apply`: implement from `tasks.md` → `openspec archive` → commit. Assumes the schema is present.

### Decision 5: Inline git rules, no external git-hygiene skill
The minimalist schema bundles an `openspec-git-discipline` skill; we don't adopt it. `apply` inlines
the repo's existing convention (commit as Pim Snel, no self-promoting trailers, one change per commit,
no push — a rebuild verifies nix changes).

### Deferred (not decided here)
- **Commit the vendored schema vs gitignore it** — depends on the target project's `.gitignore`; a
  per-project call, not fixed by this change.
- Where the change records the schema **source URL** (project.md vs a change field) — minor.

## Naming
Schema, commands, and repo all use `tinychange`: schema `tinychange`; commands
`/mip:tinychange-explore` and `/mip:tinychange-apply`; repo `speclib/openspec-tinychange-schema`.

## External deliverable (drafted here, created outside this HM change)
`speclib/openspec-tinychange-schema` must contain:
- `openspec/schemas/tinychange/schema.yaml` (the validated `specs`+`tasks` schema) and `templates/`.
- `README.md` — what tinychange is and when to use it.
- `AGENT_INSTALL.md` — the exact steps the cc-command runs to vendor + validate the schema.

## Risk
`openspec schema` is experimental; the schema.yaml format may change across OpenSpec releases, which
would require re-generating the public schema. Low effort, but a real maintenance edge.
