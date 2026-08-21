## 1. Flake integration

- [x] 1.1 Add `linny-mcp.url = "github:linden-project/linny-mcp-server"` (+ `inputs.nixpkgs.follows = "nixpkgs"`) to `flake.nix`
- [x] 1.2 Apply `inputs.linny-mcp.overlays.default` on dapperehaan (nixpkgs overlay)
- [x] 1.3 Import `inputs.linny-mcp.nixosModules.linny-mcp` into dapperehaan's config

## 2. Secrets (agenix)

- [x] 2.1 `secrets/secrets.nix` entries + deploy-key `.age` created
- [x] 2.2 token(s) minted + `linny-mcp-tokens.age` created
- [x] 2.3 `./RUNME.sh rekey` — both secrets encrypt for dapperehaan (deploy decrypted them successfully)
- [x] 2.4 Wire both secrets in dapperehaan's config (`age.secrets.*`, owned by the `linny-mcp` user)

## 3. dapperehaan service

- [x] 3.1 Configure `services.linny-mcp`: enable, `listenAddress = "192.168.100.2"`, `port = 8765`, `publicHostname = "secondbrain.pimsnel.com"`, `corpusPath = "/var/lib/secondbrain"`, `stateDir = "/var/lib/linny-mcp/personal"`, `tokensFile = <agenix>`, `quarantine = true`, `readOnly = false`, `ntfyTopicURL = null`
- [x] 3.2 Ensure `/var/lib/secondbrain` exists and is owned by `linny-mcp` (tmpfiles)

## 4. Corpus git-sync (bidirectional)

- [x] 4.1 Add a clone-bootstrap oneshot: if `/var/lib/secondbrain` is empty, `git clone git@github.com:mipmip/secondbrain` using the deploy key (`GIT_SSH_COMMAND`), as the `linny-mcp` user
- [x] 4.2 Add a git-sync unit (service + timer) running `git-sync -n` in `/var/lib/secondbrain` as `linny-mcp`, with a server git identity (`linny-mcp@dapperehaan`), branch sync + syncNewFiles enabled, and the deploy key; cadence 30s
- [x] 4.3 Confirm ordering: clone (RemainAfterExit) before linny-mcp; git-sync requires clone, after network-online

## 5. durer reverse proxy

- [x] 5.1 Add nginx vhost `secondbrain.pimsnel.com` (new file `durer-server/secondbrain.nix`): `enableACME`, `forceSSL`, `locations."/".proxyPass = "http://192.168.100.2:8765"`
- [x] 5.2 Add SSE-safe settings: `proxy_buffering off`, `proxyWebsockets` (HTTP/1.1), long `proxy_read_timeout`

## 6. Out-of-repo (manual) steps

- [x] 6.1 DNS A-record `secondbrain.pimsnel.com` → durer (ACME cert issued, HTTPS live)
- [x] 6.2 RW deploy key registered on `github.com/mipmip/secondbrain` (git-sync pushes/pulls)
- [x] 6.3 Claude Online + Mobile MCP client configured

## 7. Evaluation checks (pre-deploy)

- [x] 7.1 `nix eval` dapperehaan `services.linny-mcp.listenAddress` → `192.168.100.2` ✓
- [x] 7.2 `nix eval` dapperehaan `corpusPath`/`stateDir` under `/var/lib` ✓; `tokensFile` wired to agenix `.path`
- [x] 7.3 `nix eval` durer vhost `secondbrain.pimsnel.com` → proxyPass `http://192.168.100.2:8765`, enableACME ✓

## 8. Rollout

- [x] 8.1 Deploy durer first (public path) — ACME issued the cert, vhost live
- [x] 8.2 Deploy dapperehaan over LAN `192.168.2.22` — corpus cloned, linny-mcp binds `192.168.100.2:8765`, git-sync running (fixed a stateDir-missing 226/NAMESPACE crash by adding tmpfiles rules for `/var/lib/linny-mcp/personal`)

## 9. Post-deploy verification

- [x] 9.1 `curl https://secondbrain.pimsnel.com/healthz` reachable end-to-end (502 resolved); currently reports `degraded` due to a tracked aider artifact (see below)
- [x] 9.2 `/mcp` rejects unauthenticated requests (HTTP 401); authenticated client configured
- [x] 9.3 Bidirectional git-sync operational (GitHub↔`/var/lib/secondbrain`); the pushed `.aider` removal pulled through
- [x] 9.4 Confirm the service is bound only to the mesh — listens on `192.168.100.2:8765`, not a public interface
- [x] 9.5 Degraded mode cleared: `.aider.chat.history.md` untracked from `mipmip/secondbrain`; healthz `status:ok, degraded:false`
