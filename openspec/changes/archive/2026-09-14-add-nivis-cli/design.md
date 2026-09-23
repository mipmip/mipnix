## Context

See `proposal.md` — Why. The relevant current state:

- `modules/programs/dev/infra/iac.nix` defines `flake.modules.nixos.dev-infra-iac`,
  whose outer function is already `{ inputs, ... }` and whose inner module is
  `{ config, pkgs, ... }` with `environment.systemPackages = with pkgs; [ … ]`.
  It is imported by `role-devbox` (`modules/ROLES/nixos-devbox.nix`).
- Two existing modules already pull a binary straight out of a flake input into
  `environment.systemPackages`: `tui/tmux.nix` (`inputs.skull`) and
  `desktop/apps/markdown.nix` (`inputs.mip`). `tmux.nix` is the cleaner of the
  two — `markdown.nix` redundantly re-binds `inputs` in the inner module args,
  shadowing the outer binding.
- Upstream nivis exposes `packages.<system>.nivis` (and `.default`, the same
  derivation) for the three systems mipnix builds, plus `aarch64-darwin`.
- `flake.lock` carries 32 nixpkgs nodes across 31 distinct revisions. 13 inputs
  declare `follows`; 19 do not.

## Goals / Non-Goals

**Goals:**
- One command, `nix flake update nivis`, is the complete upgrade path.
- No growth in the number of nixpkgs revisions in the lock.
- The wiring is indistinguishable in shape from `inputs.skull` in `tmux.nix`, so
  the next person adding a tool has one pattern to copy, not two.

**Non-Goals:**
- Retrofitting `follows` onto the other 19 inputs. That is
  [mipnix-7txh](../../../.beans/mipnix-7txh--make-my-own-flake-inputs-follow-mipnix-nixpkgs.md),
  a change that can break twelve rebuilds at once; this one is purely additive
  and should not be held hostage to it.
- Darwin. `dev-infra-iac` is a NixOS module.
- Replacing or deprecating `terraform`/`opentofu`. nivis sits beside them.

## Decisions

### Unpinned `github:` ref over a tag or a path

`nivis.url = "github:nivis-project/nivis"` resolves to `main` HEAD, the only
branch upstream has.

| alternative | why not |
|-------------------------------------|--------------------------------------------------|
| `github:nivis-project/nivis/v0.7.0` | a tag never moves, so `nix flake update` is a no-op — it cannot satisfy the upgrade requirement |
| `path:/home/pim/gh.nivis-project/nivis` | the flake would only evaluate on the one machine holding the working copy |
| a `stable` branch upstream | the strictly better semantics (always a released version), but it blocks this change on upstream work; considered and deferred |

The residual risk is that `main` can run ahead of the newest tag and carry
unreleased commits. Today it does not — `main` HEAD `d142ff5f` *is* the commit
`v0.7.0` dereferences to — and since upstream is mine, the cost of landing a bad
commit is a `git revert` there rather than a pin here. If that stops being true,
the `stable` branch is the escape hatch, and it is a one-line change to the URI.

For local iteration, `--override-input nivis path:/home/pim/gh.nivis-project/nivis`
does the job without the committed flake ever depending on that directory.

### `follows` on nixpkgs, verified rather than assumed

`nivis.inputs.nixpkgs.follows = "nixpkgs"`. Upstream declares
`inputs.nixpkgs.url = "nixpkgs"` (an indirect registry ref) and locks it at
`9eac87a1` (2026-06-14) — a revision mipnix does not otherwise carry, so without
`follows` the lock gains a 33rd nixpkgs and nivis gets its own Go toolchain and
glibc, sharing nothing with the system closure.

The usual objection to `follows` is that it moves a tool off the nixpkgs its own
CI validated. That was settled empirically before writing this: building
`github:nivis-project/nivis#nivis` with `--override-input nixpkgs` pointed at
mipnix' locked 26.05 (`fcb8fcd6`) succeeds and yields a `bin/nivis` reporting
`nivis 0.7.0`. It is a `buildGoModule` package whose `vendorHash` is a
fixed-output hash of the Go module set and therefore nixpkgs-independent; only
the toolchain moves.

### `environment.systemPackages` in `iac.nix`, not a home-manager module

The alternative is a `pim-nivis` home-manager module, the shape used by
`teejay`, `beandex` and `rme`. Rejected for this tool: the request was
explicitly "next to terraform and tofu", those live in `iac.nix`, and
`tmux.nix`/`markdown.nix` establish that a NixOS module consuming a flake input
directly is already idiomatic here. The cost is that nivis is scoped to
`role-devbox` hosts and unavailable on darwin — acceptable, and reversible by
moving the one line.

Follow `tmux.nix`: take `inputs` from the outer function only, and leave the
inner module args (`{ config, pkgs, ... }`) alone.

### Reconciling the `flake-structure` spec

`flake-structure`'s **External Input Minimization** requirement says
personally-maintained packages should be local packages and that external inputs
are "reserved for third-party dependencies". This change contradicts it — and so
does the repository, which carries ~15 personally-maintained external inputs
against two genuinely co-developed local packages (`mipbar`, `mipvim`). Rather
than add a sixteenth violation silently, the delta rewrites the requirement
around the distinction that actually holds: co-developed vs. independently
released. Nothing in `packages/` moves; only the written rule changes to match
practice.

## Risks / Trade-offs

- **A flake update lands an unreleased or broken `main` commit.** → Failure is at
  build time, not runtime, and the previous generation still boots. Roll back by
  reverting `flake.lock`. Upstream is mine, so the durable fix is a `stable`
  branch (deferred, one-line change here).
- **A future nivis revision stops building on 26.05.** → Surfaces as a build
  failure during the flake update that introduced it. Escape hatch: drop the
  `follows` line for that input and accept the extra nixpkgs node.
- **Trade-off: linux + devbox only.** nivis will not be on a Mac or on
  non-devbox hosts. Accepted; moving to a home-manager module is a one-line
  change if that becomes wrong.
- **The `flake-structure` delta is a written-rule change touching a spec this
  change does not otherwise implement.** → Kept deliberately narrow: one
  requirement, no file moves, no effect on existing local packages.

## Migration Plan

Additive; nothing to migrate. Land the input and the module entry together —
`nix flake check` fails on an input that nothing references only if evaluation
forces it, so an intermediate commit with the input alone is not a useful
checkpoint. Roll back by reverting the commit and rebuilding; no state, no
services, no files outside the store are touched.
