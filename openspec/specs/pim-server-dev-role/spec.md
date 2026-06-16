# Pim Server Dev Role


### Requirement: server-dev-role-provides-claude-code

The `role-pim-cli-server-dev` home-manager role SHALL provide Claude Code (via the existing `vibecoding-claude-code-config` module) so that it is available in the environments of hosts that import the role.

#### Scenario: role imported on a host

- **WHEN** a home configuration imports `role-pim-cli-server-dev`
- **THEN** `programs.claude-code` SHALL be enabled and the `claude` command SHALL be available on the host, including the configured `mip:` slash commands

### Requirement: server-dev-role-is-additive

The `role-pim-cli-server-dev` role SHALL be additive and composed alongside `role-pim-cli-minimal`, following the existing sibling-role convention, rather than replacing or re-importing the minimal role.

#### Scenario: composing minimal and server-dev

- **WHEN** a home configuration imports both `role-pim-cli-minimal` and `role-pim-cli-server-dev`
- **THEN** the base CLI environment from minimal SHALL remain intact and the server-dev tooling SHALL be layered on top without conflict

### Requirement: minimal-role-unchanged

`role-pim-cli-minimal` SHALL NOT include Claude Code, so that hosts using only the minimal role (including aarch64 Raspberry Pi hosts) are unaffected by this change.

#### Scenario: minimal-only host

- **WHEN** a host imports only `role-pim-cli-minimal` (and not `role-pim-cli-server-dev`)
- **THEN** Claude Code SHALL NOT be installed on that host

### Requirement: durer-uses-server-dev-role

The `pim@durer` home configuration SHALL import `role-pim-cli-server-dev` in addition to `role-pim-cli-minimal`.

#### Scenario: durer environment

- **WHEN** the `pim@durer` home configuration is built and deployed
- **THEN** the `durer` server SHALL have Claude Code available for interactive use over SSH
