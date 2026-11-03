# Proposal

## Why

Hermes runs on peterspav and takes commands over Matrix. In the car, the Claude app with voice works better: Claude can pass a task to Hermes, follow it up and read the result aloud. That needs a remote MCP server that Claude can reach. Custom connectors are called from Anthropic's servers, so the server needs a public HTTPS address. durer already provides that for linny-mcp.

## What Changes

- Turn on Hermes' built-in API server on peterspav, bound to `127.0.0.1:8642`, with `API_SERVER_KEY` from agenix.
- New service `hermes-mcp` on peterspav: a small Python MCP server (streamable HTTP) on the nebula address. It checks a bearer token and offers four tools on top of Hermes' `/v1/runs` API:
  - `start_task`
  - `task_status`
  - `approve`
  - `stop_task`
- durer gets a vhost `hermes.pimsnel.com` with TLS, proxying over nebula. It only admits Anthropic's egress range `160.79.104.0/21`.
- Claude connects with a fixed `Authorization: Bearer` header (the "Request headers" beta that linny-mcp already uses). The token check sits behind one function so OAuth via Authelia can replace it later ([mipnix-lygs](../../../.beans/mipnix-lygs--authelia-als-inlog-en-oauth-server.md)).
- A lobby entry for hermes-mcp.

## Capabilities

### New Capabilities

- `hermes-mcp`: remote MCP access to Hermes on peterspav from Claude, including authentication, the tool set and the public route via durer.

### Modified Capabilities

(none)

## Impact

- `modules/HOSTS/peterspav-laptop/hermes.nix`: API server environment.
- New `packages/hermes-mcp/` and `modules/HOSTS/peterspav-laptop/hermes-mcp.nix`.
- New `modules/HOSTS/durer-server/hermes-mcp.nix`.
- Secrets: `hermes-api-key.age` (peterspav), `hermes-mcp-token-hash.age` (peterspav).
- DNS: an A/AAAA record for `hermes.pimsnel.com` pointing at durer.
- A public endpoint that can make Hermes run commands. It is guarded by the bearer token, the IP allowlist and Hermes' own approvals.
