<!-- Epic: .beans/mipnix-xj48--deploy-linny-mcp-secondbrain-production.md -->

## Why

The linny-mcp server (`github.com/linden-project/linny-mcp-server`) exposes the
Linny secondbrain notebook (`github.com/mipmip/secondbrain`) to MCP clients, but
only runs locally today. We want it in production so Claude Online and Claude
Mobile can query and update the secondbrain securely from anywhere. The upstream
project is built for exactly this: a hardened NixOS module that refuses public
binds, bearer-token auth, and a "TLS terminates upstream" topology — which maps
cleanly onto our durer (reverse proxy) + nebula mesh + dapperehaan (node) setup.

## What Changes

- Add `linny-mcp` as a flake input; apply its `overlays.default` and import its
  `nixosModules.linny-mcp` on dapperehaan.
- Run `services.linny-mcp` on **dapperehaan**, bound to the mesh IP
  `192.168.100.2:8765` (RFC1918 → accepted by the binary with no override),
  `publicHostname = "secondbrain.pimsnel.com"`, corpus at **`/var/lib/secondbrain`**
  (outside `/home`, because the unit sets `ProtectHome = true`), `quarantine = true`,
  `readOnly = false` (writable).
- Add a **durer** nginx vhost `secondbrain.pimsnel.com` (ACME + forceSSL) reverse
  proxying over nebula to `192.168.100.2:8765`, with SSE-safe settings
  (`proxy_buffering off`, HTTP/1.1, long read timeout) for the MCP streamable transport.
- Add **bidirectional git-sync** of the corpus: a systemd unit running `git-sync`
  as the `linny-mcp` user (clone bootstrap + periodic sync), pushing agent writes and
  pulling remote edits through GitHub as the hub.
- Add two agenix secrets: `linny-mcp-tokens` (hashed bearer-token records) and a
  `secondbrain-deploy-key` (ed25519 SSH key whose public half is a **read/write**
  deploy key on `mipmip/secondbrain`), both encrypted for `[ pim dapperehaan ]`.
- Leave `ntfyTopicURL = null` for now (degraded-mode alerts deferred — see
  `.beans/mipnix-2dyz`).

Manual, out-of-repo steps (documented in tasks): create the `secondbrain.pimsnel.com`
DNS A-record → durer; register the deploy key on GitHub; mint bearer token(s) with
`gen-token`; configure the Claude Online/Mobile MCP client with the token.

## Capabilities

### New Capabilities
- `linny-mcp-hosting`: Production hosting of the linny-mcp secondbrain server —
  flake/overlay/module integration, the hardened service on dapperehaan (mesh bind,
  corpus location, writable quarantine mode), the durer TLS-terminating reverse
  proxy, bearer-token secret handling, and bidirectional corpus git-sync.

### Modified Capabilities
<!-- None. The new secondbrain vhost is additive; existing durer-nginx-* specs are
     unchanged. -->

## Impact

- `flake.nix` — new `linny-mcp` input (follows nixpkgs).
- `modules/HOSTS/dapperehaan-server/` — new module wiring `services.linny-mcp`,
  the corpus dir + clone bootstrap, the git-sync unit, and the two agenix secrets.
- `modules/HOSTS/durer-server/configuration.nix` — new `secondbrain.pimsnel.com`
  nginx vhost.
- `secrets/secrets.nix` — `linny-mcp-tokens.age` and `secondbrain-deploy-key.age`
  recipients `[ pim dapperehaan ]`.
- External: DNS record, GitHub deploy key, and the MCP client config (manual).
- Depends on the nebula mesh (durer↔dapperehaan) already in place.
