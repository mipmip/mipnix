## 1. Flake Input Setup

- [x] 1.1 Add `nix-openclaw` input to `flake.nix` pointing to `github:openclaw/nix-openclaw`
- [x] 1.2 Verify flake evaluates cleanly with `nix flake show`

## 2. Guest SSH Host Key (agenix identity)

- [x] 2.1 Guest uses auto-generated SSH host key (read public key from running VM instead of pre-generating)
- [x] 2.2 Add `clawone` public key to `secrets/secrets.nix` as a new identity variable
- [x] 2.3 No separate encrypted host key needed — guest auto-generated key persists in microvm volume
- [x] 2.4 Guest host key persists across reboots via /var volume (mounted at microvm startup)
- [x] 2.5 Configure agenix inside the clawone guest NixOS config (imported agenix.nixosModules.default)

## 3. Matrix Bot Password Secret

- [ ] 3.1 Create `secrets/matrix-openclaw-password.age` encrypted to `[pim, clawone]` containing the Matrix bot password
- [x] 3.2 Add agenix secret declaration in clawone guest config to decrypt `matrix-openclaw-password.age` to a file path

## 4. OpenClaw Gateway (NixOS module)

- [x] 4.1 Import `inputs.nix-openclaw.nixosModules.openclaw-gateway` in the clawone guest config
- [x] 4.2 Enable `services.openclaw-gateway` with systemd service
- [x] 4.3 Configure OpenAI as the AI provider (model: openai/gpt-4.1)
- [x] 4.4 Configure Matrix channel with server URL `https://nuremberg.pimnsnel.com`, bot user `@openclaw1:nuremberg.pimnsnel.com`, and password file from agenix

## 5. Workspace Documents

- [x] 5.1 Create minimal AGENTS.md in the guest config directory
- [x] 5.2 Create minimal SOUL.md in the guest config directory
- [x] 5.3 Create minimal TOOLS.md in the guest config directory
- [x] 5.4 Wire workspace documents into the openclaw-gateway config (deployed via environment.etc to /etc/openclaw/workspace/)

## 6. Deploy and Verify

- [ ] 6.1 Build dapperehaan config (includes clawone guest with openclaw)
- [ ] 6.2 Deploy to dapperehaan with `nixos-rebuild switch`
- [ ] 6.3 SSH into clawone guest and verify `systemctl status openclaw-gateway` is active
- [ ] 6.4 Verify agenix decrypted the Matrix bot password inside the guest
- [ ] 6.5 Run `openclaw login` inside the guest to authenticate with OpenAI (manual, one-time)
- [ ] 6.6 Send a test message in a Matrix room and verify the bot responds
