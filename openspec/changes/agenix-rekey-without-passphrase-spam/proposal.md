## Why

`agenix --rekey` prompts for the SSH key passphrase once per `.age` file (41 files currently). Neither `age` nor `rage` supports ssh-agent because the agent protocol only does signing, while age decryption needs X25519 key exchange. The workaround is `ssh-to-age`: convert the SSH key to a native age identity once (1 passphrase prompt), then use that for all decrypt/rekey operations. The same problem affects `new_nebula_node` which calls `age --decrypt` three times.

## What Changes

- Add a `rekey` command to RUNME.sh that creates a temporary age identity via `ssh-to-age`, runs `agenix --rekey` with it, then shreds the temp file
- Extract a shared `with_age_identity` helper so both `rekey` and `new_nebula_node` use the same pattern
- Update `new_nebula_node` to use the shared helper instead of calling `age --decrypt -i ~/.ssh/id_ed25519` directly

## Capabilities

### New Capabilities
- `agenix-rekey-helper`: Temporary age identity pattern for passphrase-free agenix/age operations in RUNME.sh

### Modified Capabilities

## Impact

- `RUNME.sh`: New `rekey` command, refactored `new_nebula_node` function, new shared `with_age_identity` helper
- Requires `ssh-to-age` available at runtime (via `nix shell nixpkgs#ssh-to-age` or added to system packages)
- No changes to NixOS modules or secrets.nix
