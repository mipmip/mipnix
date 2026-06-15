## Why

Quarto 1.9.x (shipped by nixpkgs 26.05, currently `1.9.37`) regressed behavior that
worked before. Rather than chase the upstream fix, the fastest path back to a working
setup is to pin Quarto to the 1.7.34 release from nixpkgs 25.11 (which is known-good for
this use). The `nixpkgs-2511` input already exists in `flake.nix`, so this is a small,
localized version pin.

## What Changes

- Rebase the existing `quarto` overlay (`modules/nix/overlays/apps.nix`) so it builds from
  `nixpkgs-2511`'s Quarto (1.7.34) instead of the default 26.05 Quarto (1.9.37), keeping
  the existing `extraRPackages` / `extraPythonPackages` customization (sourced from 25.11
  for a consistent stack).
- No changes at the consumption sites — `tex.nix` and the mipvim quarto plugin keep using
  `quarto`, which now resolves to the pinned 1.7.34 build.
- Document this as a temporary pin: revert (drop the `nixpkgs-2511` base) once 1.9.x no
  longer breaks the affected workflow.

## Capabilities

### New Capabilities

- `quarto-version-pin`: Quarto is pinned to the nixpkgs 25.11 release (1.7.34) via the apps
  overlay, with the project's R/Python extras, until the 1.9.x regression is resolved.

## Impact

- `modules/nix/overlays/apps.nix`: thread `inputs` into the overlay module args; import
  `nixpkgs-2511` for the build platform; change `quarto = prev.quarto.override {...}` to
  override `pkgs2511.quarto`, with `extraRPackages`/`extraPythonPackages` sourced from
  `pkgs2511`.
- Consumers unchanged: `modules/programs/tex/tex.nix` (`quarto`) and
  `packages/mipvim/config/plugins/markdown/quarto.nix` get the pinned build automatically.
- Eval cost: a 25.11 nixpkgs instantiation is added to the overlay (the input is already
  locked). Acceptable.
- Global pin: applies to every host/system using the overlay (a tool-version preference,
  not host-specific).
- Verified: `nixpkgs-2511#quarto` is `1.7.34` and its `.override` accepts
  `extraRPackages` + `extraPythonPackages` (vs. 26.05's `1.9.37`).
