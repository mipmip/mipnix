## Why

Janine wants her own AI assistant reachable via Matrix, using the same OpenAI subscription and clawone microvm infrastructure. Running a second OpenClaw instance alongside the existing one is lightweight (~250MB extra RAM) and avoids the overhead of a separate VM.

## What Changes

- Add a second OpenClaw gateway instance on clawone-vm running on port 18790
- New system user `openclaw-janine` with state dir `/var/lib/openclaw-janine/`
- New systemd services: `openclaw-install-janine` and `openclaw-gateway-janine`
- Matrix bot user `@openclaw-janine:pimsnel.com` on nuremberg.pimsnel.com
- Dutch-language SOUL.md for Janine's assistant personality
- Wrapper scripts for CLI access to each instance (`openclaw-pim`, `openclaw-janine`)
- Fix `pimnsnel.com` typo to `pimsnel.com` in existing specs

## Capabilities

### New Capabilities
- `openclaw-multi-instance`: Support for multiple OpenClaw gateway instances on the same guest, each with separate user, config, state, and Matrix bot identity

### Modified Capabilities
- `openclaw-gateway`: Fix hostname typo (pimnsnel.com -> pimsnel.com) in spec scenarios
- `microvm-guest-hosting`: Fix hostname typo (pimnsnel.com -> pimsnel.com) in spec scenarios

## Impact

- `modules/HOSTS/dapperehaan-server/guests/clawone-vm/configuration.nix`: New systemd services, user, wrapper scripts
- `modules/HOSTS/dapperehaan-server/guests/clawone-vm/documents-janine/`: Janine's workspace documents
- `openspec/specs/openclaw-gateway/spec.md`: Typo fix
- `openspec/specs/microvm-guest-hosting/spec.md`: Typo fix
- Post-deploy: run `onboard` for Janine's instance, create Matrix bot user on nuremberg.pimsnel.com
