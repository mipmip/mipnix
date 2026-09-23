## ADDED Requirements

### Requirement: mip-init-command-provisioned

The `mip:init` Claude Code slash command SHALL be defined as an attribute of
`modules/programs/dev/vibecoding/_cc-commands.nix` and therefore deployed to
`~/.claude/commands/mip:init.md` by the `vibecoding-claude-code-config`
home-manager module, alongside the existing `mip:` commands.

#### Scenario: command deployed by home-manager

- **WHEN** the `vibecoding-claude-code-config` home-manager module is activated
- **THEN** `~/.claude/commands/mip:init.md` SHALL exist as a Nix-store symlink and
  `/mip:init` SHALL be invocable in Claude Code

#### Scenario: command carries a description

- **WHEN** the command file is read
- **THEN** its frontmatter SHALL carry a `description` so the command appears in the
  slash-command listing, consistent with the other `mip:` commands

### Requirement: interactive-project-interview

`/mip:init` SHALL interview the user before scaffolding, rather than assuming
defaults. It SHALL ask what the project is about, whether to register the project
with a central OpenSpec store, whether to create a `flake.nix`, and which version
control system to use.

#### Scenario: project purpose

- **WHEN** `/mip:init` runs
- **THEN** it SHALL ask what the project is about, and use the answer to write the
  project's `AGENTS.md` overview and the initial beans milestones

#### Scenario: central OpenSpec store

- **WHEN** `/mip:init` runs
- **THEN** it SHALL ask whether the project should be registered with a central
  OpenSpec store, list the machine's registered stores via `openspec store list` so
  the user can pick an existing one, and on confirmation register the project with
  the chosen store

#### Scenario: store registration declined

- **WHEN** the user declines store registration
- **THEN** the project SHALL be initialized with a repo-local `openspec/` directory
  only, and no store SHALL be registered or created

#### Scenario: flake.nix

- **WHEN** `/mip:init` runs
- **THEN** it SHALL ask whether a `flake.nix` is wanted (for tests, a dev shell, or
  packaging) and SHALL create one only if the user agrees

#### Scenario: version control choice

- **WHEN** `/mip:init` runs
- **THEN** it SHALL ask whether the project uses `jj` or `git`, defaulting to `jj`,
  and SHALL use the answer to write the matching `scripts/ship-change.sh`

### Requirement: openspec-and-beans-initialized

`/mip:init` SHALL leave the project with both OpenSpec and Beans fully initialized,
with the beans issue prefix derived from the project repository name so bean ids read
`<repo-name>-<id>`.

#### Scenario: both tools initialized

- **WHEN** `/mip:init` completes
- **THEN** `openspec/` SHALL exist (via `openspec init`) and `.beans/` plus
  `.beans.yml` SHALL exist (via `beans init`)

#### Scenario: beans prefix matches the repo name

- **WHEN** the project repository directory is named `widgets`
- **THEN** `.beans.yml` SHALL carry `prefix: widgets-`, so bean ids read like
  `widgets-rn3b`

#### Scenario: prefix set after init

- **WHEN** the beans prefix is applied
- **THEN** it SHALL be written into `.beans.yml` after `beans init` (which accepts no
  prefix flag), and `beans check` SHALL pass afterwards

#### Scenario: tinychange schema offered

- **WHEN** `/mip:init` completes
- **THEN** it SHALL report that the `tinychange` schema is available from
  https://github.com/speclib/openspec-tinychange-schema and can be installed into the
  project for small changes

### Requirement: agents-md-beans-convention

`/mip:init` SHALL write an `AGENTS.md` containing the Beans-as-epics convention, with
every occurrence of the issue prefix templated to the project repository name rather
than left as `mipnix`. `CLAUDE.md` SHALL be a symlink to `AGENTS.md` so every agent
reads one source of truth.

#### Scenario: Beans section present and templated

- **WHEN** `AGENTS.md` is written for a repository named `widgets`
- **THEN** it SHALL contain a `## Beans` section instructing the agent to check out
  `@.beans/widgets-<id>-*.md` when an issue like `widgets-rn3b` is referenced, to
  treat beans as epics for OpenSpec proposals, to link the bean from `proposal.md`,
  to set the bean status to `in-progress` when used for a proposal, and to record
  `openspec-link:` in the bean frontmatter on archive

#### Scenario: allowed statuses enumerated

- **WHEN** the `## Beans` section is written
- **THEN** it SHALL list the statuses the agent may set — `in-progress`, `todo`,
  `draft`, `completed`, `scrapped` — and SHALL state that `updated_at` may be
  updated, and that no other part of a task file may be modified

#### Scenario: CLAUDE.md is a symlink

- **WHEN** `/mip:init` completes
- **THEN** `CLAUDE.md` SHALL be a symlink pointing at `AGENTS.md`, so the two cannot
  drift

### Requirement: ship-command-applicable

`/mip:init` SHALL scaffold everything `/mip:ship` depends on, so `/mip:ship` works in
the new project without further setup.

#### Scenario: ship script present and VCS-matched

- **WHEN** `/mip:init` completes
- **THEN** `scripts/ship-change.sh` SHALL exist and be executable, SHALL refuse to
  proceed when the change's `tasks.md` still has unchecked tasks, SHALL run the gate
  before archiving, and SHALL commit and push using the version control system the
  user chose

#### Scenario: CHANGELOG ready for the ship step

- **WHEN** `/mip:init` completes
- **THEN** `CHANGELOG.md` SHALL exist with an `## [Unreleased]` section, which
  `/mip:ship` step 3 appends to

#### Scenario: gate enforces coverage

- **WHEN** a `flake.nix` was requested
- **THEN** `nix flake check` SHALL run build, tests, and a coverage gate of ≥70%
  overall and ≥80% on core packages, matching the gate `/mip:ship` documents

#### Scenario: first ship fails until tests exist

- **WHEN** `/mip:ship` is run on a project that has no tests yet
- **THEN** the coverage gate SHALL fail and the ship SHALL abort before archiving or
  committing, and `/mip:init` SHALL have warned the user that tests come before the
  first ship

#### Scenario: no flake requested

- **WHEN** the user declined a `flake.nix`
- **THEN** `/mip:init` SHALL still scaffold `scripts/ship-change.sh` and
  `CHANGELOG.md`, and SHALL state that the gate step will not work until a flake
  exists (offering `/mip:flaker`)
