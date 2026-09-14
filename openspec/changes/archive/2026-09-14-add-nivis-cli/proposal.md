# Add the nivis CLI to the devbox toolchain

**Bean**: [mipnix-fjpq](../../../.beans/mipnix-fjpq--make-the-nivis-cli-available-alongside-terraform-a.md)

## Why

`nivis` ("experimental terraform nix mariage") is my own tool for driving
Terraform/OpenTofu provider resources as first-class Nix values. It belongs in
the same toolbox as `terraform`, `opentofu` and `terraform-docs`, but today it
is not installed anywhere — reaching it means `nix run github:nivis-project/nivis`
every time.

Upstream is already a well-formed flake exposing `packages.<system>.nivis` for
all three systems mipnix builds, so this is a wiring change, not a packaging
one.

### Spike findings

Verified before writing this proposal, not assumed:

1. **It builds on mipnix' nixpkgs.** `nix build github:nivis-project/nivis#nivis
   --override-input nixpkgs github:NixOS/nixpkgs/fcb8fcd6` (mipnix' locked
   26.05) succeeds and produces a single `bin/nivis` reporting `nivis 0.7.0`.
   The `follows` is therefore safe, not a gamble.
2. **The `follows` removes a real lock node.** nivis pins its own nixpkgs at
   `9eac87a1` (2026-06-14) — a revision mipnix does not otherwise carry. Without
   `follows` the lock grows from 32 nixpkgs nodes to 33, each with its own
   toolchain and no closure sharing.
3. **`main` currently *is* the release.** `main` HEAD is `d142ff5f`, and the
   annotated tag `v0.7.0` dereferences to that same commit. `main` is the only
   branch upstream has.

## What Changes

- **New flake input.** `nivis.url = "github:nivis-project/nivis"` — unpinned, so
  `nix flake update nivis` always lands on the newest upstream commit. A pinned
  `v0.x.y` ref is explicitly rejected: a tag never moves, so it could not satisfy
  the "a flake update picks up the latest version" requirement. A local path
  (`path:/home/pim/gh.nivis-project/nivis`) is equally rejected — the committed
  flake must build on every host, not just the one with the working copy.
- **`nivis.inputs.nixpkgs.follows = "nixpkgs"`**, per spike finding 1 and 2.
- **One entry in `modules/programs/dev/infra/iac.nix`**, in
  `environment.systemPackages` beside `terraform` and `opentofu`, following the
  existing pattern of `inputs.skull` in `modules/programs/tui/tmux.nix` and
  `inputs.mip` in `modules/programs/desktop/apps/markdown.nix`. That module
  already takes `{ inputs, ... }` on its outer function, so no signature change.
- **CLI only.** The upstream flake also exposes `tutor` (tutorial scaffolder) and
  `fake-providers`; neither ships here.
- **No configuration.** nivis needs nothing under `~/.config` today. When it
  grows config, that is its own change.

## Capabilities

### New Capabilities
- `nivis-cli`: the `nivis` binary is present in the infrastructure toolchain on
  devbox hosts, sourced from a moving upstream flake ref that follows mipnix'
  nixpkgs, so that `nix flake update nivis` is the whole upgrade procedure.

### Modified Capabilities
- `flake-structure`: its **External Input Minimization** requirement states that
  for personally-maintained packages (`mipmip/*`) "integration as a local package
  SHALL be preferred over external flake input" and that "external flake inputs
  SHALL be reserved for third-party dependencies". This change deliberately does
  the opposite, and so does existing practice — the flake already carries ~15
  personally-maintained external inputs (`mip`, `teejay`, `skull`, `rme`,
  `beandex`, `huphop`, …) against only two local packages that are genuinely
  co-developed with mipnix (`mipbar`, `mipvim`). The requirement is narrowed to
  match the real distinction: **co-developed** components live in `packages/`;
  **standalone tools with their own release cycle** are consumed as external
  flake inputs.

## Impact

- `flake.nix` — one input added (two lines, with the `follows`).
- `flake.lock` — one `nivis` node added; no new nixpkgs node, thanks to the
  `follows`.
- `modules/programs/dev/infra/iac.nix` — one package added.
- Reaches hosts through `role-devbox` (`modules/ROLES/nixos-devbox.nix`), a
  NixOS module, so **linux-only**. Darwin is out of scope; if nivis ever needs to
  follow me to a Mac, that is a move to a `pim-nivis` home-manager module.
- No runtime configuration, no services, no secrets, no new closure beyond the
  Go binary itself.
