# opencode-provisioning Specification

## ADDED Requirements

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
