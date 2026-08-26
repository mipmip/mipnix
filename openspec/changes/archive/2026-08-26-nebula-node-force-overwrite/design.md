## Context

After `automate-nebula-node-wiring`, `new_nebula_node` handles pre-existing artifacts
three different ways: certificates trigger a hard `exit 1` (nebula.sh:41-44); the
`nebula.nix` write and the machine-key/`systems`/`publicKeys` edits silently skip when
present. This is inconsistent and blocks re-provisioning (e.g. a reinstalled host whose
SSH host key changed) or finishing a partial run. The command runs under `gum`, which
already provides `gum confirm` for yes/no prompts (used elsewhere in the RUNME suite),
and is invoked both interactively and from `new_host`.

## Goals / Non-Goals

**Goals:**
- Replace the certificate hard-exit with an overwrite prompt; declining continues the
  run (repair flow) instead of exiting.
- Prompt before overwriting an existing `nebula.nix`.
- Prompt before overwriting an existing machine-key binding **only when the key
  differs**; identical keys skip silently.
- Provide a `FORCE` env override that auto-confirms all prompts for non-interactive use.
- Handle each conflict independently.

**Non-Goals:**
- Prompting for `systems` membership or `publicKeys` entries — these carry no
  distinguishing content, so add-if-absent stays.
- Deleting/rekeying/rebuilding automatically (unchanged; still manual).
- Changing the IP allocation, group selection, or signing logic beyond making the
  signing step conditional.
- Backing up overwritten files (git already tracks them; the operator reviews the diff).

## Decisions

### Decision: `gum confirm` per conflict, gated by `FORCE`
Each conflict point calls a small helper — `_confirm_overwrite "<what>"` — that returns
true when `FORCE` is set, otherwise runs `gum confirm "<what> already exists — overwrite?"`.
Centralising keeps prompt wording consistent and makes `FORCE` a single check.
_Alternative rejected:_ one upfront "overwrite everything?" prompt — loses the
per-artifact granularity the user asked for ("node OR some stuff from a node").

### Decision: Declining certificate overwrite continues, does not exit
Certificate generation (IP prompt, group selection, sign, encrypt) becomes a guarded
block: run it when the certs are absent or the operator confirmed overwrite; otherwise
print "keeping existing certificates" and fall through to the secrets/wiring steps. This
turns a previously fatal state into a repair path, which is the main motivation.
_Alternative rejected:_ decline → `exit 0`. Simpler, but defeats the "finish a partial
run" use case.

### Decision: Machine-key prompt only on a *differing* key
Comparing the existing binding's key against the current host key avoids a pointless
prompt on every re-run of an unchanged host. Extract the existing key from the
`<node> = "…";` line, compare to `MACHINE_KEY`; equal → skip silent, differ → prompt,
absent → add. Overwrite replaces just the value on that line.

### Decision: `FORCE` propagation from `new_host`
`FORCE` is read from the environment, so `new_host` (or an operator) can export it
before calling `new_nebula_node`. `new_host` itself is not changed to always force —
forcing stays an explicit opt-in.

## Risks / Trade-offs

- [Replacing a machine-key line with sed could corrupt secrets.nix] → Match the exact
  `^  <node> = "…";` line and substitute only its quoted value; guard behind the
  differs-check and rely on the operator's rebuild/eval to catch a bad edit.
- [Conditional cert block introduces a code path where signing is skipped but later
  steps assume cert files exist] → The later steps only reference the `.age` files by
  name (already on disk in the keep-existing case), so they remain valid.
- [`FORCE` makes destructive overwrite silent] → It is opt-in and off by default;
  interactive runs still prompt.
- [`gum confirm` unavailable] → The command already depends on `gum` and checks for it
  up front; no new dependency.

## Migration Plan

Additive to `new_nebula_node`; no data migration. Land the updated `RUNME.d/nebula.sh`.
Rollback is reverting that file. Depends on `automate-nebula-node-wiring` being present
(ideally archived first so the `nebula-node-provisioning` base spec exists).

## Open Questions

- Should `new_host` default to `FORCE` when it just created the host directory (so its
  own generated files never prompt)? Current design: no — forcing is always explicit.
