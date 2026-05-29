## 1. Fix hostname typo in specs

- [x] 1.1 Fix `pimnsnel.com` to `pimsnel.com` in `openspec/specs/openclaw-gateway/spec.md`
- [x] 1.2 Fix `pimnsnel.com` to `pimsnel.com` in `openspec/specs/microvm-guest-hosting/spec.md`

## 2. Janine's system user and services

- [x] 2.1 Add `openclaw-janine` system user and group in clawone guest configuration.nix
- [x] 2.2 Add `openclaw-install-janine` systemd service
- [x] 2.3 Add `openclaw-gateway-janine` systemd service (port 18790)

## 3. Workspace documents for Janine

- [x] 3.1 Create `documents-janine/AGENTS.md` in guest config directory
- [x] 3.2 Create `documents-janine/SOUL.md` with Dutch-language personality
- [x] 3.3 Create `documents-janine/TOOLS.md` in guest config directory
- [x] 3.4 Deploy Janine's workspace documents via environment.etc

## 4. CLI wrapper scripts

- [x] 4.1 Create `openclaw-pim` wrapper script
- [x] 4.2 Create `openclaw-janine` wrapper script
- [x] 4.3 Add both wrapper scripts to environment.systemPackages

## 5. Deploy and verify

- [x] 5.1 Build and deploy to dapperehaan
- [x] 5.2 Create Matrix bot user @openclaw-janine on nuremberg.pimsnel.com
- [x] 5.3 Run onboard for Janine's instance
- [x] 5.4 Run openclaw models auth login for Janine's instance
- [x] 5.5 Verify openclaw-gateway-janine service is running
- [x] 5.6 Send test message and verify Dutch response
