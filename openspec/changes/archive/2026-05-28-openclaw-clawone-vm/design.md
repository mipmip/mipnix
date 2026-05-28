## Context

The clawone microvm guest on dapperehaan-server is set up by the `microvm-on-dapperehaan` change — a minimal NixOS VM with outbound internet. This change layers OpenClaw on top: gateway service, OpenAI provider, and Matrix bot.

The `nix-openclaw` flake provides a Home Manager module (`programs.openclaw`) that manages the gateway as a systemd user service on Linux. It requires workspace documents (AGENTS.md, SOUL.md, TOOLS.md) and supports bundled plugins.

Secrets are managed via agenix in this repo. The `secrets/secrets.nix` file maps `.age` files to authorized public keys (user SSH keys + host SSH keys). The repo is public, so no plaintext secrets can be committed.

## Goals / Non-Goals

**Goals:**
- OpenClaw gateway running as a persistent service inside clawone-vm
- OpenAI (Codex) as the AI provider, authenticated via `openclaw login`
- Matrix bot responding in a room on nuremberg.pimnsnel.com
- Matrix bot password managed via agenix
- Pre-generated SSH host key for clawone so agenix can decrypt secrets inside the VM

**Non-Goals:**
- Multiple AI providers or Bedrock fallback (future work)
- Inbound access to OpenClaw from outside the VM (Matrix is outbound)
- Custom OpenClaw plugins beyond bundled defaults
- Running OpenClaw as a system service (Home Manager user service is the nix-openclaw way)

## Decisions

### Use nix-openclaw Home Manager module

Add `github:openclaw/nix-openclaw` as a flake input. Enable `programs.openclaw` in the guest's Home Manager config with gateway service.

**Why:** This is the official Nix integration. It manages the gateway systemd user service, plugin installation, and workspace config declaratively. Avoids the Docker packaging bugs we encountered.

**Alternatives considered:**
- Docker inside the VM: Already hit packaging bugs (HEARTBEAT.md, codex harness). Nix-native is more reliable.
- Manual install: Loses declarative management and reproducibility.

### Pre-generate SSH host key for clawone and add to agenix

Generate an ed25519 host key pair before first deployment. The public key goes into `secrets/secrets.nix` as `clawone` identity. The private key is encrypted with agenix (encrypted to pim + dapperehaan) and deployed to the guest via microvm shared directory or agenix inside the guest.

**Why:** agenix decrypts secrets using the host's SSH key. Since clawone is a microvm, its host key doesn't exist until we create one. Pre-generating lets us encrypt secrets for the VM before it boots. This follows the same pattern as nebula keys for other hosts.

**Alternatives considered:**
- Decrypt on dapperehaan host and share via microvm volume: Simpler but breaks the agenix-per-host model. The host would need access to all guest secrets.
- Generate key at first boot and re-key: Requires manual re-encryption after first boot, error-prone.

### Matrix bot password via agenix

Create `secrets/matrix-openclaw-password.age` encrypted to `[pim, clawone]`. The guest's agenix config decrypts it to a file path that OpenClaw can read.

**Why:** The Matrix bot uses password auth. The password is persistent and sensitive — fits the agenix model perfectly. Same pattern as other service credentials in this repo.

### OpenAI auth via `openclaw login` (manual, one-time)

After deployment, SSH into the guest and run `openclaw login` to do the OAuth flow with OpenAI. The session token persists in the microvm's persistent volume at `/var/lib/microvms/clawone/`.

**Why:** OpenAI Plus subscription auth uses OAuth, not a static API key. The token is stored in OpenClaw's local state (`~/.openclaw/`), which lives on the persistent volume. This doesn't need agenix since it's runtime state, not a pre-provisioned secret.

**Alternatives considered:**
- Static API key via agenix: Would work for API-only plans, but the user has a Plus subscription which uses OAuth login.

### Workspace documents in the guest config

Create minimal AGENTS.md, SOUL.md, and TOOLS.md as part of the Nix config (inline or as files in the guest directory). These are required by nix-openclaw.

**Why:** nix-openclaw requires these files in its documents directory. They configure the AI's behavior and available tools. Starting minimal and iterating is fine.

## Risks / Trade-offs

[Risk] `openclaw login` OAuth token may expire, requiring manual re-login → Mitigation: Monitor for auth failures. If frequent, investigate static API key as alternative.

[Risk] nix-openclaw version may have the same codex harness routing bug we hit in Docker → Mitigation: Pin to a version with the fix, or configure `agents.harness` explicitly in openclaw config.

[Risk] Sharing the pre-generated SSH host key between agenix and microvm requires careful wiring → Mitigation: Use microvm's `shared` directories or inline the key via agenix on the host, then bind-mount into the guest.

[Risk] Matrix bot may need specific permissions on the Matrix server (room join, message send) → Mitigation: The bot user is already created on nuremberg.pimnsnel.com. Verify room membership and permissions before deploying.

## Open Questions

- What Matrix room should the bot join? A dedicated room, or an existing one?
- Should the workspace documents (SOUL.md etc.) be customized for specific use cases, or start with defaults?
