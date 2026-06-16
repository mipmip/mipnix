## 1. Rebase the quarto overlay on nixpkgs-2511

- [x] 1.1 Added `inputs` to the module args (`{ withSystem, inputs, ... }:`).
- [x] 1.2 Added `pkgs2511 = import inputs.nixpkgs-2511 { system = prev.stdenv.hostPlatform.system; config.allowUnfree = true; }` in a `let` inside the `withSystem` body.
- [x] 1.3 Changed the override to `pkgs2511.quarto.override { extraRPackages = [ pkgs2511.rPackages.reticulate ]; extraPythonPackages = ...; }`.

## 2. Build and verify

- [x] 2.1 Built `.#nixosConfigurations.lego2.pkgs.quarto` (real build, exit 0).
- [x] 2.2 Verified `quarto --version` → `1.7.34` (not 1.9.37); closure includes `r-reticulate-1.43.0` and Python `numpy`/`matplotlib`/`plotly`/`pandas` (+tabulate) from the 25.11 stack.
- [x] 2.3 Run the workflow that broke under 1.9.x and confirm it works again on 1.7.34 (live, post-deploy).
- [x] 2.4 Confirmed consumers reference `quarto` unchanged (`tex.nix:7`); they get the pinned build with no edits.

## 3. Document revert

- [x] 3.1 Added a comment in the overlay: temporary 1.9.x-regression pin; revert by basing `quarto` on `prev` (returns to 26.05).
