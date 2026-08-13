## Why

`new_nebula_node` currently reacts inconsistently when a node — or only *part* of a
node — already exists: existing certificates cause a hard `exit 1`, while an existing
`nebula.nix`, machine-key binding, or `systems` entry are silently skipped. This
blocks the common cases of re-provisioning a reinstalled host (new SSH host key) or
completing a partial previous run, and it forces the operator to hand-delete files to
get past the abort. The operator should instead be *asked* whether to overwrite.

## What Changes

- When certificates for the node already exist, `new_nebula_node` prompts to
  regenerate/overwrite instead of aborting. Declining keeps the existing certs and
  continues with the remaining steps (repair flow) rather than exiting.
- When the node's `nebula.nix` already exists, prompt to overwrite instead of silently
  leaving it unchanged.
- When the machine-key let-binding already exists but its key **differs** from the
  machine's current host key, prompt to overwrite the binding (identical keys are still
  skipped silently).
- A `FORCE=1` environment variable (and matching behaviour when invoked from
  `new_host`) answers all overwrite prompts affirmatively for non-interactive runs.
- Each conflict is handled independently so "some stuff from a node already exists"
  resolves per-artifact rather than all-or-nothing.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `nebula-node-provisioning`: Existing-artifact handling changes from abort/silent-skip
  to per-artifact overwrite prompting (certificates, `nebula.nix`, machine-key
  binding), with an optional `FORCE` override.

## Impact

- `RUNME.d/nebula.sh` — the certificate-existence guard, the `nebula.nix` write guard,
  and the machine-key registration gain `gum confirm` overwrite prompts and honour
  `FORCE`.
- Certificate generation becomes conditional (skipped when the operator declines to
  overwrite), so the signing/IP/group steps must tolerate being bypassed.
- Builds on the `nebula-node-provisioning` capability introduced by the
  `automate-nebula-node-wiring` change (which should be archived first).
- `systems` membership and cert/key `publicKeys` entries remain skip-if-present (no
  meaningful content to overwrite).
