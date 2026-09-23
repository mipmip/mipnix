## Why

Most changes in this config are tiny — a one-file edit, a small alias, a config toggle — yet
each drags the full OpenSpec ceremony (proposal + design + tasks + spec) behind it. The part
that actually matters for a tiny change is the *spec delta* (even small changes can shift the
specs) and a short *tasks* list; the proposal/design phases are overhead. OpenSpec 1.10 supports
custom workflow schemas, so we can drive tiny changes through a lean `specs → tasks` schema
("tinychange") and expose two shortcut commands. A spike confirmed the whole flow works: a change
created with `--schema tinychange` scaffolds only `specs` + `tasks` (no proposal/design), validates,
archives/syncs the delta, and supports `skip_specs: true` for pure-refactor changes with no spec
impact.

## What Changes

- Add two Claude Code commands to `modules/programs/dev/vibecoding/_cc-commands.nix`:
  - `/mip:tinychange-explore <intent>` — ensure the `tinychange` schema is installed in the current
    project (install on demand if absent), do a lightweight exploration with a FULL scan of existing
    specs, then `openspec new change <name> --schema tinychange` and write the spec delta (or set
    `skip_specs: true`) plus `tasks.md`.
  - `/mip:tinychange-apply <name>` — implement from `tasks.md`, `openspec archive` (sync the delta),
    and commit per the repo's git convention (Pim Snel, no self-promotion; no push).
- The schema itself lives in a separate public repo, `speclib/openspec-tinychange-schema`
  (`openspec/schemas/tinychange/` + templates + README + `AGENT_INSTALL.md`), following OpenSpec's
  promoted distribution route (an agent follows `AGENT_INSTALL.md` to copy the schema into a project
  — there is no `openspec install <url>` command). home-manager ships only the commands, not the
  schema; the command installs the schema on demand.

## Capabilities

### New Capabilities
- `tinychange-commands`: two cc-commands providing a lean `specs → tasks` OpenSpec workflow for very
  small changes — schema-presence self-heal (install if absent), spec-scan + delta on explore, and
  implement + archive + commit on apply.

## Impact

- **Code**: `modules/programs/dev/vibecoding/_cc-commands.nix` (two new command entries).
- **External prerequisite**: the `speclib/openspec-tinychange-schema` repo must exist and expose a
  reachable `AGENT_INSTALL.md`; the commands reference it. (Repo contents drafted in design; creating
  that repo is outside this home-manager change.)
- **Dependencies**: OpenSpec ≥ 1.10 (custom schemas), already installed.
- **Risks**: `openspec schema` is flagged experimental (format may change). No native URL install, so
  the command vendors the schema via `AGENT_INSTALL.md`. Whether the vendored schema is committed per
  project is deferred (depends on the target repo's `.gitignore`).
