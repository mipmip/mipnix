## Context

Quarto is defined once, in the apps overlay (`modules/nix/overlays/apps.nix`):

```
flake.overlays.apps = final: prev:
  withSystem prev.stdenv.hostPlatform.system ({ config, ... }: {
    quarto = prev.quarto.override {
      extraRPackages = [ prev.rPackages.reticulate ];
      extraPythonPackages = ps: with ps; [ plotly numpy pandas matplotlib tabulate ];
    };
  });
```

`prev.quarto` is 26.05's Quarto (`1.9.37`). Consumers — `modules/programs/tex/tex.nix`
(`quarto`) and `packages/mipvim/config/plugins/markdown/quarto.nix` — use this overlaid
`quarto` on PATH; none pin a version themselves.

`flake.nix` already has `nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11"`.

Verified:
- `nixpkgs-2511#quarto.version` = `1.7.34`; 26.05 = `1.9.37`.
- 25.11 `quarto.override.__functionArgs` includes `extraRPackages` and
  `extraPythonPackages` (both `true`) — the existing override interface is unchanged.
- `(nixpkgs-2511.quarto.override { extraRPackages = []; extraPythonPackages = ps: []; }).version`
  evaluates to `1.7.34`.

## Goals / Non-Goals

**Goals:**
- Quarto resolves to 1.7.34 (from 25.11) everywhere, fastest path to a working Quarto.
- Preserve the R (reticulate) + Python (plotly/numpy/pandas/matplotlib/tabulate) extras.
- Keep the single-definition shape (overlay is the one place quarto is configured).

**Non-Goals:**
- Identifying/fixing the specific 1.9.x regression upstream (downgrade is the chosen
  workaround; the precise broken behavior is not pinned down).
- Per-host pinning (this is a global tool-version preference).
- Overriding Quarto's src/version on the 26.05 derivation (fragile for a bundled tool).

## Decisions

### Rebase the overlay's quarto on `nixpkgs-2511`

Thread `inputs` into the overlay, import 25.11 for the build platform, and override
`pkgs2511.quarto`:

```
{ withSystem, inputs, ... }: {
  flake.overlays.apps = final: prev:
    withSystem prev.stdenv.hostPlatform.system ({ config, ... }:
      let
        pkgs2511 = import inputs.nixpkgs-2511 {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      in {
        quarto = pkgs2511.quarto.override {
          extraRPackages = [ pkgs2511.rPackages.reticulate ];
          extraPythonPackages = ps: with ps; [ plotly numpy pandas matplotlib tabulate ];
        };
      });
}
```

**Why**: keeps quarto defined in one place (the overlay); consumers need no change; the
override interface is identical on 25.11, so only the base nixpkgs changes.

**Alternatives considered**:
- *`overrideAttrs` to swap src/version on 26.05's quarto to 1.7.34* — rejected: Quarto is a
  bundled derivation (deno/pandoc/typst pinned together); swapping just src is fragile.
- *Import 25.11 quarto directly at each consumer* — rejected: scatters the pin and drops
  the R/Python override unless re-applied.

### R/Python extras sourced from 25.11 (not 26.05 `prev`)

`extraRPackages`/`extraPythonPackages` come from `pkgs2511`, not `prev`, so the whole
Quarto stack (quarto + R + Python deps) is consistent at the 25.11 release.

**Why**: mixing 25.11 quarto with 26.05 R/Python packages risks subtle incompatibility;
a single-release stack is the safe default. (User-confirmed: full consistency.)

### Temporary pin with a documented revert

This is a workaround for a 1.9.x regression, not a permanent preference.

**Revert criteria**: when 1.9.x (or a later 26.05 Quarto) no longer breaks the affected
workflow, drop the `pkgs2511` base and return to `prev.quarto.override {...}` (back to the
26.05 version), then re-test the workflow.

## Risks / Trade-offs

- **[Risk] Cross-release coupling with the rest of the env** → the 25.11 Quarto stack runs
  alongside 26.05 system libs. Quarto bundles most of its own deps, so risk is low, but a
  rendering pipeline that calls system pandoc/tex could see version skew. *Mitigation*:
  Quarto bundles pandoc/typst/deno; `tex.nix` also installs `pandoc`/texlive separately —
  watch for any pandoc-version interaction during verification.
- **[Risk] allowUnfree on the 25.11 import** → set to match the rest of the config; only
  relevant if a quarto dep is unfree. Harmless if not.
- **[Trade-off] Extra nixpkgs eval** → a second nixpkgs instantiation in the overlay; modest
  eval cost, input already locked.

## Migration Plan

1. Edit `modules/nix/overlays/apps.nix`: add `inputs` to module args, import
   `nixpkgs-2511`, override `pkgs2511.quarto` with the (25.11-sourced) extras.
2. Build a host/config that uses quarto; confirm `quarto --version` resolves to `1.7.34`.
3. Verify the previously-broken Quarto workflow now works on 1.7.34.

**Rollback**: revert the overlay to `prev.quarto.override {...}` (26.05, 1.9.37); rebuild.

## Open Questions

- The exact 1.9.x regression is not identified (downgrade chosen as the fast fix). If it's
  worth tracking upstream later, capture the specific broken behavior then.
