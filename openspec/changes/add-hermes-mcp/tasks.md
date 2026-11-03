## 1. Hermes API server

- [ ] 1.1 Read `/v1/runs` request and response shapes in Hermes' code (`api_server_runs.py`, approval, events)
- [ ] 1.2 User: create `secrets/hermes-api-key.age` with `API_SERVER_KEY=<random>`; register it in `secrets/secrets.nix` for peterspav
- [ ] 1.3 Add the secret to `environmentFiles` and `API_SERVER_HOST=127.0.0.1` to `environment` in `hermes.nix`

## 2. hermes-mcp

- [ ] 2.1 Write `packages/hermes-mcp/` (FastMCP, httpx, the four tools, authenticator middleware)
- [ ] 2.2 Test against a stub `/v1/runs` server: token check, each tool, Hermes unreachable; wire as a flake check
- [ ] 2.3 User: generate a token locally, store `sha256` hex in `secrets/hermes-mcp-token-hash.age`
- [ ] 2.4 Write `modules/HOSTS/peterspav-laptop/hermes-mcp.nix`: hardened unit on `192.168.100.16:8766`, both secrets, lobby entry

## 3. durer

- [ ] 3.1 Write `modules/HOSTS/durer-server/hermes-mcp.nix` with ACME, streaming proxy and the allowlist
- [ ] 3.2 User: DNS record `hermes.pimsnel.com` to durer

## 4. Rollout

- [ ] 4.1 Deploy peterspav, restart `hermes-agent`, check `/v1/health` on 127.0.0.1
- [ ] 4.2 Deploy durer; check that a request from outside the range gets `403`
- [ ] 4.3 User: add the custom connector `https://hermes.pimsnel.com/mcp` with header `Authorization: Bearer <token>`
- [ ] 4.4 User: from the Claude app, give a task, follow it up in the same session, approve a command, stop a task
