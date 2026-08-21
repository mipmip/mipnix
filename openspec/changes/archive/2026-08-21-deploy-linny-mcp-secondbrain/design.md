## Context

linny-mcp ships a hardened NixOS module (`nixosModules.linny-mcp`) and an overlay
(`overlays.default` → `pkgs.linny-mcp`). Verified from the source:

- The systemd unit sets `ProtectHome = true` with `ReadWritePaths = corpusPath ++
  stateDir` and **no** `BindReadOnlyPaths` — so a corpus under `/home` is invisible
  in the sandbox. Corpus must live outside `/home`.
- The service runs as a real `linny-mcp` system user (no DynamicUser), home =
  `stateDir`. Anything else that touches the working tree must run as this user.
- `internal/config/bind.go` accepts loopback, `ip.IsPrivate()` (incl. 192.168.0.0/16),
  link-local, and 100.64.0.0/10; it refuses public IPs and `0.0.0.0`. dapperehaan's
  mesh IP `192.168.100.2` is private → accepted with no override.
- Auth is static bearer tokens: `gen-token` prints a one-time secret (for the client)
  plus a hashed JSON record (for `tokensFile`). The module takes only a *path*.
- The server never owns git; an external process keeps the corpus in sync.

Our infra already provides the rest: durer terminates TLS / runs ACME nginx and is a
nebula lighthouse; dapperehaan is a live mesh node at `192.168.100.2`.

## Goals / Non-Goals

**Goals:**
- Serve `mipmip/secondbrain` to Claude Online + Mobile over HTTPS, securely.
- Keep the server off any public interface (bind mesh IP; TLS terminates on durer).
- Writable brain: agent edits persist and propagate back to GitHub.
- Reuse existing patterns (durer nginx vhosts, agenix SSH-key-for-repo).

**Non-Goals:**
- ntfy / degraded-mode alerting (deferred → `.beans/mipnix-2dyz`).
- OIDC auth (upstream defers it; static bearer tokens only).
- Multi-notebook hosting (single "personal" notebook to start).
- Changing the corpus format, the indexer, or upstream linny-mcp behaviour.
- Automating the DNS record, GitHub deploy-key registration, or client config
  (these are manual, one-time, and documented).

## Decisions

### Decision: Corpus at `/var/lib/secondbrain`, not `/home/pim/secondbrain`
The deploy doc's example uses `/home/pim/secondbrain`, but `ProtectHome = true`
makes `/home` empty in the sandbox and `ReadWritePaths` cannot punch back through it.
Place the corpus at `/var/lib/secondbrain`, owned by `linny-mcp`, with
`stateDir = /var/lib/linny-mcp/personal`. Bonus: cleanly separates the server mirror
from the interactive `~/secondbrain` on laptops.
_Alternative rejected:_ relax `ProtectHome` to `"read-only"` and keep `/home` — weakens
the upstream hardening for no benefit.

### Decision: Bind the mesh IP `192.168.100.2` (no override)
Confirmed `bind.go` accepts RFC1918. Binding the mesh IP lets durer reach it over
nebula while staying off every public interface. No `--i-know-what-im-doing`.
_Alternative rejected:_ bind loopback — unreachable by a remote proxy.

### Decision: Writable + bidirectional git-sync, GitHub as hub
`readOnly = false`, `quarantine = true` (default). A systemd unit runs `git-sync`
(nixpkgs) as the `linny-mcp` user in `/var/lib/secondbrain`: bootstrap-clone if
absent, then periodically commit local (agent) changes, pull --rebase, and push.
GitHub is the convergence point for both the server and the laptops (which already
run `git-sync`). Quarantine keeps agent-created docs in a separate area, minimizing
collisions with hand-edited notes.
_Alternatives rejected:_ (a) read-only mirror — user wants a writable brain; (b) let
linny-mcp own git — upstream explicitly refuses this.

### Decision: RW deploy key via agenix, mirroring the restic ssh-key pattern
Pushing requires write. Generate an ed25519 key, store it as
`secondbrain-deploy-key.age` (recipients `[ pim dapperehaan ]`), and register its
public half as a **read/write** deploy key on `mipmip/secondbrain`. git-sync uses it
via `GIT_SSH_COMMAND`. Deploy keys are per-repo, so blast radius is limited to this
one repo (vs. a broad PAT).
_Alternative rejected:_ a GitHub PAT — broader scope, worse blast radius.

### Decision: SSE-safe nginx vhost on durer
MCP's streamable-HTTP transport needs `proxy_buffering off`, HTTP/1.1, and a long
`proxy_read_timeout`, otherwise long-lived `/mcp` streams stall. Otherwise it mirrors
the existing umami/matrix vhosts (enableACME + forceSSL + proxyPass).

### Decision: Token bootstrap out-of-band
Mint tokens with `nix run github:linden-project/linny-mcp-server -- gen-token …`
before/independently of deploy; put the hashed record in `linny-mcp-tokens.age` and
the one-time secret in the Claude client config. No token literal ever enters a Nix
option (they land world-readable in `/nix/store`).

## Risks / Trade-offs

- [Two live writers (laptop edits + agent writes) into one repo can conflict] →
  quarantine isolates agent docs; git-sync commits WIP then rebases; markdown merges
  are usually clean. Hard conflicts stop git-sync (see below).
- [git-sync stops on a hard conflict and, without ntfy, does so silently] → accepted
  for MVP; `ntfyTopicURL` wiring is the deferred `mipnix-2dyz`. Mitigate meanwhile by
  a periodic `/healthz` / sync-status check.
- [RW deploy key on dapperehaan could push bad state to secondbrain] → per-repo key
  (not account-wide), agenix-encrypted at rest, readable only by `linny-mcp`; history
  is recoverable via git + the existing restic backups of secondbrain.
- [linny-mcp and git-sync both writing the tree concurrently] → both run as the same
  `linny-mcp` user; git-sync auto-commits in-flight files. Low risk on markdown.
- [Deploying dapperehaan restarts nebula and can self-cut a mesh deploy] → deploy
  dapperehaan over its LAN IP `192.168.2.22` (established pattern), durer over public.

## Migration Plan

1. Land config (flake input, dapperehaan service + git-sync + secrets, durer vhost).
2. Out-of-band: create DNS `secondbrain.pimsnel.com` → durer; generate + register the
   RW deploy key on GitHub; `gen-token` → record into agenix, `rekey`.
3. `nix eval` sanity on both hosts.
4. Deploy **durer** (public path) → ACME issues the cert, vhost live.
5. Deploy **dapperehaan** (LAN `192.168.2.22`) → corpus clones, git-sync runs,
   linny-mcp binds the mesh IP.
6. Verify: `/healthz` via durer HTTPS; an authenticated `/mcp` handshake; an agent
   write appears on GitHub and a GitHub edit appears on dapperehaan.
7. Configure Claude Online + Mobile with the token.

Rollback: `services.linny-mcp.enable = false` + drop the durer vhost and redeploy;
the corpus and its git history remain intact.

## Open Questions

- git-sync cadence: match the laptop's ~10s, or 30s to cut push churn? (Lean 30s.)
- Token scopes: a single broad token, or `read:*` + `write:inbox` split? (Lean split.)
- Do we want a dedicated `secondbrain.pimsnel.com` cert, or a wildcard if one exists?
