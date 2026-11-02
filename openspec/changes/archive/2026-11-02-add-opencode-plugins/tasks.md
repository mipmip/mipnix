## 1. Flake inputs and official package

- [x] 1.1 Run `nix flake update unstable` and verify the input reports OpenCode
  2.1.1 with `nix eval --raw --impure --expr
  '(builtins.getFlake (toString ./.)).inputs.unstable.legacyPackages.x86_64-linux.opencode.version'`
- [x] 1.2 Add `opencode-beans` and `opencode-openspec-sidepanel` as flake inputs
  with `inputs.nixpkgs.follows = "nixpkgs"`, remove the `opencode` input and its
  comment, and verify `nix flake metadata` lists the two plugins and no
  `opencode` input
- [x] 1.3 Replace the let-bound OpenCode package with
  `inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode`,
  remove the `overrideAttrs` source workaround and its comment, and verify
  `nix build .#homeConfigurations."pim@peterspav".activationPackage` succeeds
- [x] 1.4 Update the `update = "disable"` comment to say that OpenCode updates
  through `nix flake update unstable`, and verify no tag-specific wording
  remains

## 2. Global plugins

- [x] 2.1 Append
  `${inputs.opencode-beans.packages.${pkgs.stdenv.hostPlatform.system}.default}/plugins/beans-stats`
  and the sidepanel equivalent to `programs.opencode.settings.plugins`, and
  verify the generated `opencode.json` contains both paths plus the existing
  dcp and notifier entries
- [x] 2.2 Build and switch the home configuration, run
  `opencode service restart`, and verify `opencode --version` reports 2.1.1 and
  `opencode plugin list` includes both new plugins and both existing plugins
- [x] 2.3 Open OpenCode in a project with `openspec/` and `.beans/`, and in one
  without them; verify both sidebar sections appear, the empty project reports
  unavailable instead of failing, and no plugin load error is logged
- [x] 2.4 Verify an existing provider still authenticates and a prompt succeeds,
  and that `opencode-dcp` and `opencode-notifier` still work

## 3. Update flow and follow-up

- [x] 3.1 Run `nix flake update opencode-beans opencode-openspec-sidepanel`,
  rebuild, and verify the plugin store paths stay independent of the OpenCode
  path. At this lock both plugins were already at upstream HEAD, so the revs and
  store paths stayed the same; the OpenCode path stayed the same too.
- [x] 3.2 Run `nix flake update unstable`, rebuild, and verify the OpenCode
  version follows the input while the plugin store paths stay the same. At this
  lock the input was already at nixos-unstable HEAD, so the rev and OpenCode
  path stayed the same; the plugin paths stayed the same too.
- [x] 3.3 Rebase the paused `add-opencode-go-usage` change on
  `inputs.unstable.legacyPackages.${system}.opencode` and verify its design and
  tasks no longer reference `inputs.opencode`. The paused change never
  referenced the removed input, so no edit was needed.
- [x] 3.4 Run `openspec validate add-opencode-plugins --strict` and verify it
  passes. It reports the change is valid.
- [x] 3.5 Run `git diff --check` and verify only the intended flake, module,
  artifact and lock changes are present. The check is clean; the diff covers
  `flake.lock`, `flake.nix` and `modules/programs/dev/vibecoding/opencode.nix`,
  plus the new change directory. Unrelated working-tree changes were left alone.
