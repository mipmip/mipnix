## Context

RUNME.sh is the operational script for this NixOS flake. `agenix --rekey` and `new_nebula_node` both need to decrypt `.age` files using the user's SSH key. Since `age`/`rage` cannot use ssh-agent (protocol mismatch: signing vs X25519 key exchange), every decrypt prompts for the passphrase.

The secrets are encrypted to SSH public keys (not native age recipients), so `ssh-to-age` cannot help — it produces native age identities that can't decrypt SSH-recipient-encrypted files. The solution is simpler: temporarily create an unencrypted copy of the SSH key using `ssh-keygen -p`.

## Goals / Non-Goals

**Goals:**
- Rekey all 41+ age files with a single passphrase prompt
- Decrypt in `new_nebula_node` with no additional prompts
- No unencrypted key material left on disk after the operation

**Non-Goals:**
- Changing the NixOS agenix module configuration (boot-time decryption uses host keys, not user keys)
- Switching from age to rage system-wide
- Persisting an unencrypted key between sessions

## Decisions

**1. Shared `with_age_identity` helper using trap cleanup**

A function that copies the SSH key to a temp file, removes the passphrase with `ssh-keygen -p -N ""` (prompts once), runs a callback, then shreds the file via `trap ... RETURN`. Both `rekey` and `new_nebula_node` call this helper.

Alternative: `ssh-to-age` to convert to native age identity. Rejected because secrets are encrypted to SSH public keys, not native age recipients — the converted identity cannot decrypt them.

Alternative: `rage` with ssh-agent support. Rejected because neither `age` nor `rage` supports ssh-agent (protocol limitation).

**2. `ssh-keygen -p` for passphrase removal**

Copy the SSH key to a temp file, then `ssh-keygen -p -N "" -f $tmpfile` removes the passphrase interactively (one prompt). The resulting unencrypted SSH key works directly with `age -i`.

No additional dependencies required — `ssh-keygen` is always available.

**3. `shred -u` for cleanup via trap RETURN**

Use `shred -u` to overwrite before unlinking. The trap on RETURN ensures cleanup even if the callback fails.

**4. Pass identity path to age/agenix via `-i` flag**

`agenix --rekey -i $tmpkey` and `age --decrypt -i $tmpkey` both accept `-i` for identity files. This is the standard interface.

## Risks / Trade-offs

- [Temp file briefly on disk] → `mktemp` creates with 600 permissions in `/tmp`; `shred -u` overwrites on cleanup; window is seconds
- [`shred` not effective on CoW/SSD] → Acknowledged limitation; the temp file exists for seconds regardless
