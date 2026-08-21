## ADDED Requirements

### Requirement: linny-mcp runs on dapperehaan bound to the mesh

The linny-mcp server SHALL run on dapperehaan via the upstream `nixosModules.linny-mcp`
and its overlay, bound to dapperehaan's nebula mesh IP so it is reachable only over the
overlay and never on a public interface.

#### Scenario: Bound to the mesh IP

- **WHEN** `services.linny-mcp` is enabled on dapperehaan
- **THEN** it SHALL listen on `192.168.100.2:8765` (an RFC1918 address the binary
  accepts without a bind override) and SHALL NOT bind a public address or `0.0.0.0`

#### Scenario: Serves the secondbrain notebook

- **WHEN** the service starts
- **THEN** it SHALL serve the `mipmip/secondbrain` corpus located at
  `/var/lib/secondbrain` with a disposable index under `/var/lib/linny-mcp/personal`

### Requirement: Corpus lives outside /home

The corpus and state directories SHALL be located outside `/home` (under `/var/lib`) so they are accessible inside the service sandbox, because the hardened unit sets `ProtectHome = true`.

#### Scenario: Corpus path is sandbox-accessible

- **WHEN** the corpus is configured
- **THEN** `corpusPath` and `stateDir` SHALL be under `/var/lib` (not `/home`) and
  included in the unit's `ReadWritePaths`

### Requirement: TLS terminates on durer and proxies over nebula

durer SHALL front the server with an HTTPS reverse proxy so external clients (Claude
Online and Mobile) reach it over TLS while the server itself stays on the mesh.

#### Scenario: Public HTTPS endpoint

- **WHEN** a client requests `https://secondbrain.pimsnel.com/mcp`
- **THEN** durer's nginx SHALL terminate TLS (ACME + forceSSL) and reverse-proxy the
  request over nebula to `http://192.168.100.2:8765`

#### Scenario: Streamable transport is not buffered

- **WHEN** the proxied request uses the MCP streamable-HTTP (SSE) transport
- **THEN** the vhost SHALL disable proxy buffering, use HTTP/1.1, and apply a long
  read timeout so long-lived streams are not stalled or truncated

### Requirement: Bearer tokens sourced from an encrypted file

Bearer tokens SHALL be provided to the server only as a file path sourced from agenix;
no token value SHALL appear in a Nix option.

#### Scenario: Token records come from agenix

- **WHEN** the service is configured
- **THEN** `tokensFile` SHALL point at an agenix-decrypted file (`linny-mcp-tokens`)
  owned by the service user, and no token literal SHALL be present in any Nix option or
  in `/nix/store`

#### Scenario: Unauthenticated requests are rejected

- **WHEN** a request to `/mcp` arrives without a valid `Authorization: Bearer` token
- **THEN** it SHALL be rejected, while `/healthz` SHALL remain reachable without auth

### Requirement: Writable corpus with bidirectional git-sync

The production corpus SHALL be writable (`readOnly = false`, `quarantine = true`) and
kept synchronized with `github.com/mipmip/secondbrain` in both directions by an external
git-sync process that the MCP server does not own.

#### Scenario: Agent writes propagate to GitHub

- **WHEN** the MCP server writes a (quarantined) document into the corpus
- **THEN** the git-sync unit, running as the `linny-mcp` user, SHALL commit and push it
  to `mipmip/secondbrain` using a read/write deploy key

#### Scenario: Remote edits propagate to dapperehaan

- **WHEN** a note is edited elsewhere and pushed to `mipmip/secondbrain`
- **THEN** the git-sync unit SHALL pull it into `/var/lib/secondbrain`

#### Scenario: Corpus is bootstrapped on first run

- **WHEN** `/var/lib/secondbrain` does not yet contain the repository
- **THEN** it SHALL be cloned from `mipmip/secondbrain` before the server serves it

### Requirement: Repository push authorized by a scoped deploy key

Push access SHALL use a per-repository read/write deploy key stored encrypted at rest,
not an account-wide credential.

#### Scenario: Deploy key is encrypted and service-scoped

- **WHEN** the deploy key is provisioned
- **THEN** it SHALL be an agenix secret (`secondbrain-deploy-key`) encrypted for
  `[ pim dapperehaan ]`, readable only by the `linny-mcp` user, with its public half
  registered as a read/write deploy key on `mipmip/secondbrain`
