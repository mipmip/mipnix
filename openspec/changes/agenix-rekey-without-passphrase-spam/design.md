## Context

RUNME.sh is the operational script for this NixOS flake. `agenix --rekey` and `new_nebula_node` both need to decrypt `.age` files using the user's SSH key. Since `age`/`rage` cannot use ssh-agent (protocol mismatch: signing vs X25519 key exchange), every decrypt prompts for the passphrase.

`ssh-to-age` converts an SSH ed25519 key into a native age identity. The native identity is unencrypted, so age/rage can use it without prompting.

## Goals / Non-Goals

**Goals:**
- Rekey all 41+ age files with a single passphrase prompt
- Decrypt in `new_nebula_node` with no additional prompts
- No unencrypted key material left on disk after the operation

**Non-Goals:**
- Changing the NixOS agenix module configuration (boot-time decryption uses host keys, not user keys)
- Switching from age to rage system-wide
- Persisting the age identity between sessions

## Decisions

**1. Shared `with_age_identity` helper using trap cleanup**

A function that creates a temp file via `mktemp`, runs `ssh-to-age` to populate it, exports the path, runs a callback, then shreds the file via `trap ... RETURN`. Both `rekey` and `new_nebula_node` call this helper.

Alternative: inline the pattern in each function. Rejected because it duplicates the security-critical cleanup logic.

**2. Use `nix shell nixpkgs#ssh-to-age` for runtime availability**

Rather than adding `ssh-to-age` to system packages (it's only needed for this script), invoke it via `nix shell`. This avoids polluting the system closure for a rarely-used tool.

Alternative: add to `environment.systemPackages`. Rejected because rekey is an infrequent operation.

**3. `shred -u` for cleanup, with trap on both RETURN and EXIT**

Use `shred -u` to overwrite before unlinking. The trap ensures cleanup even if the operation fails mid-way.

**4. Pass identity path to age/agenix via `-i` flag**

`agenix --rekey -i $tmpkey` and `age --decrypt -i $tmpkey` both accept `-i` for identity files. This is the standard interface.

## Risks / Trade-offs

- [Temp file briefly on disk] → `mktemp` creates with 600 permissions in `/tmp`; `shred -u` overwrites on cleanup; window is seconds
- [`nix shell` adds startup latency] → Acceptable for an infrequent operation; avoids system package bloat
- [`shred` not effective on CoW/SSD] → Acknowledged limitation; the temp file exists for seconds regardless
