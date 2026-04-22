## Why

The RUNME.sh boilerplate is on v1 (no `RUNME.d/` support). The v2.0.0 boilerplate from mipmip/RUNME.sh adds auto-sourcing of `RUNME.d/*.sh` files, allowing commands to be split into separate files by concern. The current RUNME.sh has 15 commands and ~650 lines in a single file, mixing nix operations, git sync, AWS bootstrap, nebula management, and host scaffolding.

## What Changes

- Replace the v1 boilerplate one-liner with the v2.0.0 boilerplate (adds `RUNME_DIR` resolution and `RUNME.d/` auto-sourcing)
- Create `RUNME.d/` directory with commands split into logical files
- Keep RUNME.sh itself minimal — just boilerplate, shared helpers, and `runme` call
- Shared helpers (`with_age_identity`, `check_untracked`, `_nebula_ips_from_certs`) stay in RUNME.sh since they're used across multiple command files

## Capabilities

### New Capabilities
- `runme-d-split`: Split RUNME.sh commands into separate files under RUNME.d/

### Modified Capabilities

## Impact

- `RUNME.sh`: Boilerplate replaced, commands moved out to `RUNME.d/`
- New directory `RUNME.d/` with individual `.sh` files per command group
- No functional changes — all commands work identically
- `rme` completions continue to work (same `make_command` interface)
