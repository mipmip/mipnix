## Why

With the clawone microvm infrastructure in place (see `openspec/changes/microvm-on-dapperehaan/`), we can now install OpenClaw as a persistent AI assistant inside the guest. OpenClaw will use the OpenAI Plus subscription (with Codex) as its AI provider and communicate as a bot on the personal Matrix server at nuremberg.pimnsnel.com. This makes the assistant always-available and reachable from any Matrix client.

## What Changes

- Add `nix-openclaw` as a flake input
- Configure Home Manager on the clawone guest with `programs.openclaw` enabled and gateway service running
- Set up the Matrix channel pointing at nuremberg.pimnsnel.com with a dedicated bot user
- Configure OpenAI as the AI provider (auth via `openclaw login`, session persisted in microvm volume)
- Pre-generate an SSH host key for the guest and add it to agenix, enabling secret decryption inside the VM
- Store the Matrix bot password as an agenix-encrypted secret
- Create the required OpenClaw workspace documents (AGENTS.md, SOUL.md, TOOLS.md)

## Capabilities

### New Capabilities
- `openclaw-gateway`: OpenClaw gateway service running on the clawone guest with OpenAI provider and Matrix bot channel
- `clawone-secrets`: Agenix-managed secrets for the clawone guest (pre-generated SSH host key, Matrix bot password)

### Modified Capabilities

None.

## Impact

- `flake.nix`: New input (`nix-openclaw`)
- `modules/HOSTS/dapperehaan-server/guests/clawone-vm/configuration.nix`: Add Home Manager with openclaw module
- `secrets/`: New agenix-encrypted files for clawone SSH host key and Matrix bot password
- `secrets.nix` (or equivalent): Add clawone's public key as an agenix identity
- Post-deploy manual step: `openclaw login` inside the VM to authenticate with OpenAI
- Depends on: `microvm-on-dapperehaan` change being implemented first
