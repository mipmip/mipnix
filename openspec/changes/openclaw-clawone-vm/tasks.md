## 1. Flake Input Setup

- [ ] 1.1 Add `nix-openclaw` input to `flake.nix` pointing to `github:openclaw/nix-openclaw`
- [ ] 1.2 Verify flake evaluates cleanly with `nix flake show`

## 2. Guest SSH Host Key (agenix identity)

- [ ] 2.1 Pre-generate ed25519 SSH host key pair for clawone (`ssh-keygen -t ed25519 -f clawone-host-key -N ""`)
- [ ] 2.2 Add `clawone` public key to `secrets/secrets.nix` as a new identity variable
- [ ] 2.3 Encrypt the private host key with agenix: create `secrets/clawone-host-key.age` encrypted to `[pim, dapperehaan]`
- [ ] 2.4 Configure the clawone guest to receive the host key (via microvm shared directory or agenix on the host bind-mounted into guest)
- [ ] 2.5 Configure agenix inside the clawone guest NixOS config, pointing to the deployed host key

## 3. Matrix Bot Password Secret

- [ ] 3.1 Create `secrets/matrix-openclaw-password.age` encrypted to `[pim, clawone]` containing the Matrix bot password
- [ ] 3.2 Add agenix secret declaration in clawone guest config to decrypt `matrix-openclaw-password.age` to a file path

## 4. Home Manager with OpenClaw

- [ ] 4.1 Import `inputs.nix-openclaw.homeManagerModules.openclaw` in the clawone guest's Home Manager config
- [ ] 4.2 Enable `programs.openclaw` with gateway service enabled
- [ ] 4.3 Configure OpenAI as the AI provider in OpenClaw settings
- [ ] 4.4 Configure Matrix channel with server URL `https://nuremberg.pimnsnel.com`, bot username, and password file path from agenix

## 5. Workspace Documents

- [ ] 5.1 Create minimal AGENTS.md in the guest config directory
- [ ] 5.2 Create minimal SOUL.md in the guest config directory
- [ ] 5.3 Create minimal TOOLS.md in the guest config directory
- [ ] 5.4 Wire workspace documents directory into the `programs.openclaw` config

## 6. Deploy and Verify

- [ ] 6.1 Build the guest config: `nix build .#nixosConfigurations.clawone.config.system.build.toplevel`
- [ ] 6.2 Deploy to dapperehaan with `nixos-rebuild switch`
- [ ] 6.3 SSH into clawone guest and verify `systemctl --user status openclaw-gateway` is active
- [ ] 6.4 Verify agenix decrypted the Matrix bot password inside the guest
- [ ] 6.5 Run `openclaw login` inside the guest to authenticate with OpenAI (manual, one-time)
- [ ] 6.6 Send a test message in a Matrix room and verify the bot responds
