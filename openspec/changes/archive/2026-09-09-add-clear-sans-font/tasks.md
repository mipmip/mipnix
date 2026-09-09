## 1. Implementation

- [x] 1.1 Add `modules/nix/overlays/fonts.nix` defining `flake.overlays.fonts`
      with a `clear-sans` derivation (`stdenvNoCC.mkDerivation` +
      `fetchFromGitHub`), modelled on the existing
      `flake.overlays.chipsailing` in `modules/hardware/chipsailing-fingerprint.nix`.
      Pinned upstream (no tags/releases exist, project discontinued by Intel):
      - owner/repo: `intel/clear-sans`
      - rev: `1993725b24a36af21e7ebaa8977103983b608572` (main HEAD, 2023-01-07)
      - hash: `sha256-+xdetdE3Z4NlrWiEYCUO5bmf06g/+p5blkkNk+XcruQ=`
      - version: `0-unstable-2023-01-07` (nixpkgs untagged convention)
      - installPhase: `install -Dm444 TTF/*.ttf -t $out/share/fonts/truetype`
      - meta: `license = lib.licenses.asl20;` (upstream `LICENSE.txt`)
- [x] 1.2 Register the overlay in `modules/nix/channels.nix`: add
      `inputs.self.overlays.fonts` to the `nixpkgs.overlays` list of
      `flake.modules.nixos.nix-channels` (next to `inputs.self.overlays.apps`).
      Note: `nix-channels-mama` is intentionally left alone — only the
      `nixos-desktop-pim` role imports `desktop-utils-fonts`.
- [x] 1.3 Add `clear-sans` to `fontsList` in
      `modules/programs/desktop/utils/fonts.nix` (the `with pkgs; [ ... ]` list,
      near `inter`). Leave `fontconfig.defaultFonts` untouched — this change only
      makes the font available, it does not change the default sans-serif.

## 2. Verification

- [x] 2.1 `nix build .#nixosConfigurations.doornappel.config.system.build.toplevel`
      evaluates and builds without error (overlay wiring + package are valid).
      Result: `/nix/store/d4vdgc9vn06pcf4hrrwrl2dirg9azv82-nixos-system-doornappel-26.05.20260809.fcb8fcd`.
      Note: the new overlay file had to be `git add`-ed first — flakes copy only
      tracked files, so an untracked `overlays/fonts.nix` failed with
      "attribute 'fonts' missing".
- [x] 2.2 All 8 styles present. Verified pre-switch against the built closure
      rather than a live `fc-list`: `config.system.path` contains all 8
      `ClearSans-*.ttf`, and `fc-scan` reports the families/styles fontconfig
      will expose — `Clear Sans` (Regular, Italic, Bold, Bold Italic),
      `Clear Sans Light`, `Clear Sans Medium` (Regular, Italic),
      `Clear Sans Thin`. The heavier/lighter weights register as their own
      families, which is normal for a pre-variable TTF family of this size;
      `fc-list | grep -i "Clear Sans"` still matches all 8.
- [x] 2.3 Generic sans-serif untouched. `config.fonts.fontconfig.defaultFonts`
      on the built system still evaluates to
      `sansSerif = [ "Ubuntu" "Vazirmatn" ]`, and `fc-match sans-serif` on the
      running host reports `Ubuntu-R.ttf`. Clear Sans is available by name only.

## Notes

Schema source: https://github.com/speclib/openspec-tinychange-schema
(install with the guide at `AGENT_INSTALL.md` in that repo).

Why an overlay and not `packages/`: `fontsList` is a `with pkgs; [ ... ]` list,
so exposing the font as `pkgs.clear-sans` keeps the diff in `fonts.nix` to a
single word. The repo's `packages/` directory (mipbar, mipvim, pimsnel-website)
is reserved for first-party apps built from in-tree sources.
