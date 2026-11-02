# opencode-provisioning Specification

## Purpose
TBD - created by archiving change share-agent-config. Update Purpose after archive.

## Requirements

### Requirement: Commands Are Provisioned
The `vibecoding-opencode` module SHALL give `programs.opencode.commands` the
shared command set, so the `mip:` commands are invocable in opencode.

#### Scenario: Commands written
- **WHEN** the module is activated
- **THEN** every attribute of the shared command set SHALL exist as
  `~/.config/opencode/commands/<name>.md` as a Nix-store symlink
- **AND** `programs.opencode.commands` SHALL NOT be an empty attribute set

#### Scenario: The same text as Claude Code
- **WHEN** a command file under `~/.config/opencode/commands/` is compared with
  the file of the same name under `~/.claude/commands/`
- **THEN** the contents SHALL be identical, because both come from the same Nix
  attribute

### Requirement: Global Context Is Provisioned
The `vibecoding-opencode` module SHALL set `programs.opencode.context` to the
shared global context followed by the shared writing rules, so opencode receives
both in `~/.config/opencode/AGENTS.md`.

#### Scenario: The file is written
- **WHEN** the module is activated
- **THEN** `~/.config/opencode/AGENTS.md` SHALL exist as a Nix-store symlink
- **AND** it SHALL contain the global context and every writing rule

#### Scenario: A rule is changed
- **WHEN** a writing rule is changed in its single Nix definition and the
  configuration is rebuilt
- **THEN** `AGENTS.md` SHALL carry the new text
- **AND** the change SHALL have required no edit inside the opencode module

### Requirement: Skills Are Not Declared For opencode
The `vibecoding-opencode` module SHALL leave `programs.opencode.skills` unset.
opencode reads `~/.claude/skills/<name>/SKILL.md` itself, so declaring the
skills again would write a second copy for no gain.

#### Scenario: Skills available without declaration
- **WHEN** opencode starts and a skill is installed under `~/.claude/skills/`
- **THEN** the skill SHALL be listed as available in opencode
- **AND** no copy of it SHALL exist under `~/.config/opencode/skills/`

### Requirement: The Go-usage plugin is configured with an option, not a bare string
The configuration SHALL declare `@mellena1/opencode-go-usage` as a plugin entry
carrying `options`, because the plugin cannot find this machine's credential on
its own: its resolution order reads a `auth.json` that opencode 2 no longer
writes, and looks for `key` or `apiKey` fields that an OAuth credential does not
have.

#### Scenario: The plugin is declared
- **WHEN** `~/.config/opencode/opencode.json` is generated
- **THEN** `plugins` SHALL contain an entry whose `package` is
  `@mellena1/opencode-go-usage`
- **AND** that entry SHALL carry an `options.apiKey`, rather than being a bare
  package string

#### Scenario: Without the option
- **WHEN** the plugin is declared as a bare string
- **THEN** it SHALL resolve no credential, and the widget SHALL hide itself
- **AND** this SHALL be understood as the reason the option exists, not as a
  fault in the plugin

### Requirement: The credential reaches the plugin without entering the store
The access token SHALL be passed through opencode's own config substitution from
a file under the user's runtime directory. The generated configuration SHALL
contain a path and never a credential.

#### Scenario: What the generated config contains
- **WHEN** the generated `opencode.json` is inspected
- **THEN** `options.apiKey` SHALL be the literal
  `{file:{env:XDG_RUNTIME_DIR}/opencode-go-key}`
- **AND** no part of the credential SHALL appear anywhere in the Nix store

#### Scenario: The substitution resolves
- **WHEN** opencode loads the configuration
- **THEN** the `{env:…}` pass SHALL resolve first, leaving a concrete path
- **AND** the `{file:…}` pass SHALL then read and trim that file
- **AND** the user id SHALL NOT be written into any Nix expression

#### Scenario: Where the file lives
- **WHEN** the token file is written
- **THEN** it SHALL be under `$XDG_RUNTIME_DIR`, which is tmpfs owned by the
  user with mode 0700
- **AND** the file itself SHALL be mode 0600
- **AND** it SHALL NOT persist across a logout

### Requirement: The wrapper reads the credential and never writes it
opencode SHALL be wrapped so that each start extracts the active credential's
access token from `opencode.db` into the runtime-directory file. The wrapper
SHALL only read, because `opencode auth` owns that row and refreshes it.

#### Scenario: Extraction on start
- **WHEN** opencode is started
- **THEN** the wrapper SHALL select the active row from the `credential` table
  where `integration_id` identifies the opencode integration
- **AND** SHALL write that value's `access` field to the token file

#### Scenario: Nothing to extract
- **WHEN** the database is absent, holds no active row, or no longer has the
  expected shape
- **THEN** opencode SHALL still start
- **AND** no token file SHALL be left behind
- **AND** the widget SHALL hide itself, which is the intended degradation rather
  than an error

#### Scenario: The wrapper is a shell wrapper
- **WHEN** the package is assembled
- **THEN** the extraction SHALL run in a shell wrapper placed around the
  upstream binary wrapper, because `makeBinaryWrapper` does not support running
  a command before exec
- **AND** `sqlite3` and `jq` SHALL be referenced by store path rather than by a
  bare command name

#### Scenario: Concurrent access
- **WHEN** another opencode process is running and holds the database
- **THEN** the read SHALL still succeed, because the database is in WAL mode
- **AND** the wrapper SHALL issue no write of any kind

### Requirement: The provider's own authentication is left alone
The configuration SHALL NOT set `OPENCODE_API_KEY`. opencode reads that variable
itself and prefers it over the OAuth connection when activating the opencode
provider, so exporting an access token through it would change how real model
traffic authenticates.

#### Scenario: The environment stays clean
- **WHEN** opencode runs under the wrapper
- **THEN** `OPENCODE_API_KEY` SHALL be unset in its environment
- **AND** the opencode provider SHALL continue to authenticate through the
  stored OAuth connection

#### Scenario: Scope of the credential
- **WHEN** the token is supplied through `options.apiKey`
- **THEN** it SHALL reach only this plugin
- **AND** SHALL NOT influence provider selection, model availability, or any
  other plugin

### Requirement: A refreshed token is picked up on restart
The token file SHALL be rewritten on every start, so a credential refresh is
adopted without any further action. A refresh during a running session SHALL
degrade visibly rather than silently.

#### Scenario: After a refresh
- **WHEN** opencode has refreshed the credential and is started again
- **THEN** the wrapper SHALL write the new access token
- **AND** the widget SHALL resume showing current numbers

#### Scenario: During a session
- **WHEN** the credential is refreshed while a session is open
- **THEN** the widget SHALL keep its last known values with a note
- **AND** current numbers SHALL return after a restart

### Requirement: OpenCode comes from the official nixpkgs package

The `vibecoding-opencode` module SHALL set `programs.opencode.package` to the
`opencode` package from the repository's pinned `unstable` nixpkgs input. It
SHALL NOT build OpenCode from a separate `anomalyco/opencode` flake input and
SHALL NOT override the package source.

#### Scenario: The official package is selected

- **WHEN** the module is activated
- **THEN** the `opencode` on `PATH` SHALL come from the `unstable` nixpkgs input
- **AND** its reported version SHALL match that input's `opencode` package

#### Scenario: No external OpenCode pin remains

- **WHEN** the flake inputs and the module are inspected
- **THEN** there SHALL be no `opencode` flake input and no source override for
  the OpenCode derivation

#### Scenario: OpenCode follows an unstable update

- **WHEN** `unstable` is updated and the configuration is rebuilt
- **THEN** `opencode --version` SHALL report the version from the updated input
- **AND** the plugin entries SHALL continue to load without a rebuild of their
  own inputs

### Requirement: Global pinned plugins

The module SHALL install `opencode-beans` and `opencode-openspec-sidepanel`
globally through `programs.opencode.settings.plugins`, next to the existing
`opencode-dcp` and `opencode-notifier` entries. Each plugin SHALL load from the
directory produced by its own pinned flake input, and SHALL NOT be fetched from
the network at OpenCode startup.

#### Scenario: Both plugins are available in every project

- **WHEN** OpenCode starts in a project that has no local `.opencode/plugins/`
  directory
- **THEN** `opencode plugin list` SHALL include the Beans and OpenSpec sidepanel
  plugins
- **AND** OpenCode SHALL report no plugin load error

#### Scenario: Existing plugins remain installed

- **WHEN** the new entries are added
- **THEN** `opencode-dcp` and `opencode-notifier` SHALL still be listed and
  functional

#### Scenario: Plugin sources stay pinned

- **WHEN** the upstream plugin repositories change, or the machine starts
  offline
- **THEN** OpenCode SHALL load the revisions recorded in `flake.lock`
- **AND** the plugins SHALL change only after the user updates their flake
  inputs and rebuilds

#### Scenario: An unstable bump does not move the plugins

- **WHEN** only the `unstable` input is updated
- **THEN** the plugin inputs SHALL keep their locked revisions
- **AND** the plugin directories SHALL not be rebuilt from the new nixpkgs

#### Scenario: A project lacks the plugin's data

- **WHEN** a project has no `openspec/` or `.beans/` directory
- **THEN** OpenCode SHALL still start and the plugin's sidebar section SHALL
  report itself unavailable rather than preventing startup
