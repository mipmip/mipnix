## Why

The user maintains two OpenCode plugins, `opencode-beans` and
`opencode-openspec-sidepanel`, but installing them means copying a directory
into every project. Both should be available globally, and updating them should
be a deliberate, reproducible action rather than a manual copy.

OpenCode itself is still pinned to an external `anomalyco/opencode` tag because
version 2 was not in nixpkgs when the module was written. Official OpenCode
2.1.1 is now in `nixos-unstable`, so the external flake and its `src` build
workaround can be removed.

## What Changes

- Update the existing `unstable` flake input so it provides official OpenCode
  2.1.1.
- Remove the `opencode` flake input (`github:anomalyco/opencode/v2.0.29`) and the
  `overrideAttrs (_: { src = inputs.opencode; })` workaround from the
  `vibecoding-opencode` module; use `pkgs-unstable.opencode` instead.
- Add `opencode-beans` and `opencode-openspec-sidepanel` as pinned flake inputs.
  Their `nixpkgs` input follows the main stable pin, so an `unstable` bump does
  not rebuild them.
- Add the assembled plugin directories (`beans-stats` and `openspec-stats`) to
  the global `programs.opencode.settings.plugins`, next to the existing
  `opencode-dcp` and `opencode-notifier` entries.
- Document the update flow: `nix flake update` for the plugin inputs, and
  `nix flake update unstable` for OpenCode, followed by a home-manager switch
  and `opencode service restart`.
- **BREAKING**: OpenCode moves from the pinned 2.0.29 tag to the official 2.1.1
  package. The plugin API declared by the plugin repositories (2.0.31) and the
  existing plugins must be verified against it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `opencode-provisioning`: adds requirements for the official package source and
  for the two globally installed, pinned plugins. The existing commands,
  context and skills requirements are unchanged.

## Impact

- **Code**: `flake.nix`, `flake.lock`,
  `modules/programs/dev/vibecoding/opencode.nix`.
- **Dependencies**: removes the `anomalyco/opencode` input; adds
  `opencode-beans` and `opencode-openspec-sidepanel`; updates `unstable`.
- **Build surface**: the `unstable` bump also moves `ags`/mipbar, immich and the
  other packages that use `pkgs-unstable`, so the switch needs a full build and
  runtime verification.
- **OpenSpec**: supersedes the discarded `pin-opencode-2`; the paused
  `add-opencode-go-usage` change wraps the old `inputs.opencode` derivation and
  must be rebased on `unstable.opencode` before it is applied.
- **Runtime**: the plugins add two sidebar sections to every project and show
  `unavailable` where `openspec/` or `.beans/` is absent. The beans plugin also
  expects `beans`, `openspec` and `jj` on `PATH`; all three are installed.
- **Verification risk**: the sidepanel README was tested with OpenCode 2.0.29,
  while it declares `@opencode/plugin` 2.0.31. The installed 2.1.1 must load
  both plugins, the existing plugins, and provider authentication.
