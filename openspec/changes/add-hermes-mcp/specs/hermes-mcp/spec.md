## ADDED Requirements

### Requirement: public MCP endpoint via durer

Hermes SHALL be reachable as a remote MCP server at
`https://hermes.pimsnel.com/mcp` over the streamable HTTP transport. durer
SHALL terminate TLS and forward over nebula to peterspav without buffering.
durer SHALL only admit requests from Anthropic's egress range
`160.79.104.0/21`; every other source SHALL get `403`. hermes-mcp SHALL bind
the nebula address of peterspav only, and the Hermes API server SHALL bind
`127.0.0.1` only.

#### Scenario: Claude connects

- **WHEN** Claude calls `https://hermes.pimsnel.com/mcp` from
  `160.79.104.0/21` with the right bearer token
- **THEN** the MCP session SHALL be set up and the four tools SHALL be listed

#### Scenario: other source

- **WHEN** any address outside `160.79.104.0/21` calls the endpoint
- **THEN** durer SHALL answer `403` and SHALL NOT forward the request

#### Scenario: not on the LAN or the internet

- **WHEN** someone connects to peterspav on port 8642 or 8766 from outside
  the host or the nebula mesh
- **THEN** the connection SHALL be refused

### Requirement: bearer token authentication

hermes-mcp SHALL require `Authorization: Bearer <token>` on every request and
SHALL compare it against a hash kept in agenix, in constant time. The token
itself SHALL NOT be stored on peterspav or in the Nix store. The check SHALL
sit behind one authenticator interface, so OAuth can replace it without
changing the tools.

#### Scenario: missing or wrong token

- **WHEN** a request has no token or a wrong one
- **THEN** hermes-mcp SHALL answer `401` and SHALL NOT contact Hermes

#### Scenario: right token

- **WHEN** a request carries the right token
- **THEN** it SHALL be handled

### Requirement: task tools

hermes-mcp SHALL offer these tools, backed by Hermes' `/v1/runs` API with
`API_SERVER_KEY`:

- `start_task(prompt, session_id?)`: starts a run and returns its `run_id`
  and `session_id`. Passing a `session_id` continues that conversation.
- `task_status(run_id, wait_seconds?)`: returns the state, the output so far,
  and any pending approval or question. It MAY wait up to 25 seconds for a
  change before answering.
- `approve(run_id, approved, note?)`: answers a pending approval.
- `stop_task(run_id)`: stops a run.

#### Scenario: a task from the car

- **WHEN** Claude calls `start_task` with "check the backups on dapperehaan"
  and then `task_status` until the run is done
- **THEN** `task_status` SHALL return Hermes' final answer

#### Scenario: follow-up in the same conversation

- **WHEN** Claude calls `start_task` with the `session_id` from an earlier
  task
- **THEN** Hermes SHALL have the earlier exchange as context

#### Scenario: dangerous command

- **WHEN** Hermes wants to run a command that needs approval
- **THEN** `task_status` SHALL report the pending approval with the command
- **AND** the run SHALL continue only after `approve` with `approved = true`

#### Scenario: Hermes unreachable

- **WHEN** the Hermes API server is down
- **THEN** each tool SHALL return an error that says Hermes is unreachable,
  instead of failing the MCP session
