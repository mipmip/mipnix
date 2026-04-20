## Why

`agenix --rekey` prompts for the SSH key passphrase once per `.age` file (41 files currently). Neither `age` nor `rage` supports ssh-agent because the agent protocol only does signing, while age decryption needs X25519 key exchange. The secrets are encrypted to SSH public keys, so `ssh-to-age` (native age identity conversion) doesn't help either. The solution is to temporarily decrypt the SSH key via `ssh-keygen -p`, use it for all operations, then shred it. The same problem affects `new_nebula_node` which calls `age --decrypt` three times.

## What Changes

- Add a `rekey` command to RUNME.sh that creates a temporary passphrase-free copy of the SSH key, runs `agenix --rekey` with it, then shreds the temp file
- Extract a shared `with_age_identity` helper so both `rekey` and `new_nebula_node` use the same pattern
- Update `new_nebula_node` to use the shared helper instead of calling `age --decrypt -i ~/.ssh/id_ed25519` directly

## Capabilities

### New Capabilities
- `agenix-rekey-helper`: Temporary decrypted SSH key pattern for passphrase-free agenix/age operations in RUNME.sh

### Modified Capabilities

## Impact

- `RUNME.sh`: New `rekey` command, refactored `new_nebula_node` function, new shared `with_age_identity` helper
- No additional dependencies required (`ssh-keygen` is always available)
- No changes to NixOS modules or secrets.nix
