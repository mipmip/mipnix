## 1. Remove

- [x] 1.1 Confirm nothing imports `flake.modules.nixos.clawone` and no `nixosConfigurations.clawone` exists.
- [x] 1.2 Delete `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`.
- [x] 1.3 Delete `secrets/matrix-openclaw-password.age`, its line in `secrets/secrets.nix` and the `clawone` key.
- [x] 1.4 Delete `openspec/specs/openclaw-gateway/`, `openspec/specs/openclaw-multi-instance/` and `openspec/specs/clawone-secrets/`.
- [x] 1.5 Check for remaining `openclaw` or `clawone` references outside archived changes and beans.

## 2. Verify

- [x] 2.1 Evaluate `nixosConfigurations` and build dapperehaan.
- [x] 2.2 `openspec validate --all` no longer reports the three broken specs.

## 3. Outside the repository

- [x] 3.1 Deactivate `@openclaw1` and `@openclaw-janine` on Tuwunel with `users deactivate`.
