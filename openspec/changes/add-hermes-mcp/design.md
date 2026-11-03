# Design

## Context

- Hermes runs on peterspav (`192.168.100.16`) as `hermes-agent`, configured in `modules/HOSTS/peterspav-laptop/hermes.nix`, with Matrix and a dashboard on the nebula address.
- Hermes ships an API server platform (`gateway/platforms/api_server.py`). It starts when `API_SERVER_KEY` is set, listens on `API_SERVER_HOST`/`API_SERVER_PORT` (default 8642), and exposes `/v1/runs`, `/v1/runs/{id}`, `/v1/runs/{id}/events`, `/approval`, `/stop` and OpenAI-compatible routes.
- Claude custom connectors call from `160.79.104.0/21`. This account has the "Request headers" beta, which is how linny-mcp connects with a static bearer token.
- durer fronts linny-mcp in `secondbrain.nix`: ACME, `proxy_buffering off`, long timeouts, proxy over nebula.

## Goals / Non-Goals

**Goals:** give Hermes tasks from the Claude app by voice; follow up, approve, stop; nothing else reachable from the internet.

**Non-Goals:** OAuth now (bean mipnix-lygs); exposing Hermes' conversations or Matrix history; a web UI.

## Decisions

### Request flow

```
Claude ─HTTPS, Bearer─▶ durer hermes.pimsnel.com   allow 160.79.104.0/21, deny all
                          │ nebula
                          ▼
            peterspav 192.168.100.16:8766 hermes-mcp   token check, 4 tools
                          │ http://127.0.0.1:8642, Bearer API_SERVER_KEY
                          ▼
                     Hermes /v1/runs
```

### hermes-mcp in Python with the MCP SDK

`python3Packages.mcp` (1.26) is in nixpkgs and provides FastMCP with the streamable HTTP transport. hermes-mcp is one module plus `httpx`, packaged in `packages/hermes-mcp/` and run by a hardened systemd unit (`DynamicUser`, no home, only `192.168.100.16:8766`). The plugin `mcp-serve` from Hermes is not used: it is stdio only and exposes conversations instead of tasks.

### Authentication

The agenix secret holds `sha256(token)` in hex. hermes-mcp hashes the presented token and compares with `hmac.compare_digest`. The check is a Starlette middleware calling one `authenticate(request) -> bool`, the seam for OAuth later. The user generates the token locally, stores the hash with agenix, and pastes `Bearer <token>` into the connector dialog; the token never reaches the repo.

### Mapping to /v1/runs

| Tool          | Hermes call                                  |
|---------------|----------------------------------------------|
| `start_task`  | `POST /v1/runs` with input and optional `session_id` |
| `task_status` | `GET /v1/runs/{id}`, optionally reading `/events` for up to `wait_seconds` |
| `approve`     | `POST /v1/runs/{id}/approval`                |
| `stop_task`   | `POST /v1/runs/{id}/stop`                    |

The exact request and response fields are read from Hermes' code during apply and covered by a test against a stub server. `task_status` caps `wait_seconds` at 25 so a tool call stays well under Claude's timeout.

### Hermes API server

`API_SERVER_KEY` lives in a new env file secret `hermes-api-key.age`, added to `services.hermes-agent.environmentFiles`; `API_SERVER_HOST=127.0.0.1` goes into `environment`. hermes-mcp reads the same secret through its own `EnvironmentFile`. The hermes module does not restart on config change, so apply restarts `hermes-agent` by hand.

### durer

`modules/HOSTS/durer-server/hermes-mcp.nix`, copied from `secondbrain.nix`, plus:

```nginx
allow 160.79.104.0/21;
deny all;
```

ACME's HTTP-01 challenge path stays open to all, because the NixOS ACME location is separate from `/`.

### Lobby

`lobby.services.hermes-mcp` with `access = "public"`, `browse = false`, host peterspav.

## Risks / Trade-offs

- [A public path to a machine that runs commands] → three layers: IP allowlist, bearer token, Hermes approvals for dangerous commands. Hermes keeps the same tools as on Matrix.
- [The header beta changes or ends] → swap the authenticator for OAuth with Authelia (mipnix-lygs).
- [Anthropic's egress range changes] → the range lives in one place in the durer module; a blocked connector shows as "Couldn't reach the MCP server".
- [Long tasks] → start and poll instead of one blocking call.
