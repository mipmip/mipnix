## Why

OpenClaw ran in the clawone microVM on dapperehaan as a Matrix bot. That VM
no longer exists: dapperehaan imports no microvm host module and the flake
has no `clawone` system, yet its module, secrets and three specs remain.
Hermes Agent on peterspav takes over the role (`add-hermes-agent`), so the
leftovers only mislead.

## What Changes

- Delete `modules/HOSTS/dapperehaan-server/guests/clawone-vm/`.
- Delete `secrets/matrix-openclaw-password.age`, its entry in
  `secrets/secrets.nix` and the `clawone` recipient key.
- Delete the specs `openclaw-gateway`, `openclaw-multi-instance` and
  `clawone-secrets` directly. They are structurally invalid (they still
  carry delta headers such as `## ADDED Requirements`), so OpenSpec cannot
  apply a delta to them or retire them on archive.
- Deactivate the OpenClaw bot accounts on Tuwunel (`@openclaw1` and
  `@openclaw-janine`) with an admin command.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None through deltas; the change sets `skip_specs: true`. The three specs
are removed as files because their requirements are invisible to OpenSpec
and describe nothing that runs.

## Impact

- No running system changes: nothing evaluates the clawone module today.
- `secrets.nix` loses one recipient key. No other secret lists `clawone`, so
  nothing needs rekeying.
- Bean `mipnix-eurx` mentions OpenClaw and stays as history.
