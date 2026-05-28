## 1. Fix hostname typo in specs

- [x] 1.1 Fix `pimnsnel.com` to `pimsnel.com` in `openspec/specs/openclaw-gateway/spec.md`
- [x] 1.2 Fix `pimnsnel.com` to `pimsnel.com` in `openspec/specs/microvm-guest-hosting/spec.md`

## 2. Janine's system user and services

- [x] 2.1 Add `openclaw-janine` system user and group in clawone guest configuration.nix
- [x] 2.2 Add `openclaw-install-janine` systemd service (npm install, state dir `/var/lib/openclaw-janine/`, npm prefix `/var/lib/openclaw-janine/.npm-global`)
- [x] 2.3 Add `openclaw-gateway-janine` systemd service (port 18790, config from `/var/lib/openclaw-janine/openclaw.json`)

## 3. Workspace documents for Janine

- [x] 3.1 Create `documents-janine/AGENTS.md` in guest config directory
- [x] 3.2 Create `documents-janine/SOUL.md` with Dutch-language personality
- [x] 3.3 Create `documents-janine/TOOLS.md` in guest config directory
- [x] 3.4 Deploy Janine's workspace documents to `/etc/openclaw-janine/workspace/` via environment.etc

## 4. CLI wrapper scripts

- [x] 4.1 Create `openclaw-pim` wrapper script via `pkgs.writeShellScriptBin`
- [x] 4.2 Create `openclaw-janine` wrapper script via `pkgs.writeShellScriptBin`
- [x] 4.3 Add both wrapper scripts to `environment.systemPackages`

## 5. Deploy and verify

- [ ] 5.1 Build and deploy to dapperehaan with `nixos-rebuild switch`
- [ ] 5.2 Create Matrix bot user `@openclaw-janine` on nuremberg.pimsnel.com
- [ ] 5.3 Run onboard for Janine's instance inside the guest
- [ ] 5.4 Run `openclaw models auth login` for Janine's instance
- [ ] 5.5 Verify `openclaw-gateway-janine` service is running
- [ ] 5.6 Send a test message to `@openclaw-janine:pimsnel.com` in Matrix and verify Dutch response
