# Proposal

## Why

`pim-atuin` turns on `threads.capture`, so atuin already groups shell history
into threads, but reading them means typing `atuin threads list` and
`atuin threads show` for each one. atuin-threads-tui (`att`) browses the same
threads in a TUI: list, filter, search, and read one thread with its messages.
It runs the `atuin` binary and asks for JSON, so it needs atuin on the same host
and nothing else.

It lives in its own repository with its own release cycle (v0.1.0), so
`flake-structure` puts it in the external flake input category rather than
under `packages/`.

## What Changes

- `flake.nix` gains `atuin-threads-tui.url = "github:mipmip/atuin-threads-tui"`
  with `inputs.nixpkgs.follows = "nixpkgs"`.
- `modules/USERS/pim/programs/atuin.nix` adds the package to `home.packages`,
  next to the atuin configuration that captures the threads it reads.
- No new module and no role edit. Every host that imports `pim-atuin` gets
  `att`; that is every host with `role-pim-cli-full`, servers included.

## Capabilities

### New Capabilities

- `atuin-threads-browsing`: `att` is installed on every host that has atuin, and
  is built from the upstream flake rather than a local checkout.

### Modified Capabilities

None.

## Impact

- `flake.nix`, `flake.lock`, `modules/USERS/pim/programs/atuin.nix`.
- Every host with `role-pim-cli-full`: the desktop laptops, stinkie, the two
  Raspberry Pi hosts, and lavendel. The upstream flake covers x86_64-linux and
  aarch64-linux.
- Rollout: `nix flake lock`, then `rme up_home` per host.
