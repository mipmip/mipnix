## 1. The input

- [x] 1.1 Add `opencode.url = "github:anomalyco/opencode/v2.0.29"` to `flake.nix`, with a comment saying the input deliberately does not follow this repository's nixpkgs and why, and verify `nix flake metadata` resolves it to a rev
- [x] 1.2 Verify `flake.lock` records the input with a rev rather than a branch, and note the nixpkgs it brings with it

## 2. The package

- [x] 2.1 Point `programs.opencode.package` at `inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode` in `modules/programs/dev/vibecoding/opencode.nix`, replacing `unstable.opencode`
- [x] 2.2 Apply `.overrideAttrs (_: { src = inputs.opencode; })`, with a comment naming the missing `script/` directory and the import in `packages/cli/script/build.ts` that needs it
- [x] 2.3 Verify the build fails without the override, with `Cannot find module '../../../script/native-arch'`, so the comment is known to be true
- [x] 2.4 Verify the build succeeds with the override and that `bin/opencode --version` reports the pinned version
- [x] 2.5 Verify the built output carries `share/fish/vendor_completions.d/opencode.fish`, since fish is the shell in use here

## 3. The settings

- [x] 3.1 Rename `autoshare = false` to `share = "disabled"` and verify the generated `opencode.json` carries it
- [x] 3.2 Replace `autoupdate = true` with `update = "disable"` and verify the generated `opencode.json` carries it
- [x] 3.3 Rename `plugin` to `plugins`, keeping the two npm specs as bare strings, and verify they survive as strings in the generated JSON
- [x] 3.4 Rename `provider` to `providers`, keeping the anthropic `baseURL` and the amazon-bedrock region and profile, and verify both are present in the generated JSON
- [x] 3.5 Remove the `tui` block and verify no `~/.config/opencode/tui.json` is written by the new generation

## 4. It runs

- [ ] 4.1 Rebuild and verify `opencode --version` on `PATH` reports the pinned version rather than 1.18.25
- [ ] 4.2 Start opencode and verify no `configuration normalization diagnostic` is logged for any key this repository declares
- [x] 4.3 Verify `~/.config/opencode/cli.json` is a real file, not a store symlink, and still reads `theme.name = "system"`
- [ ] 4.4 Change the theme from inside opencode, restart it, and verify the change persisted
- [ ] 4.5 Verify ripgrep is reachable from the wrapper, by running a search from inside a session

## 5. What it must not affect

- [x] 5.1 Verify `programs.claude-code` is untouched and `claude` still starts with the `mip:` commands present
- [x] 5.2 Verify no other module's `unstable` reference changed

## 6. Upstream

- [ ] 6.1 Report the fileset omission to `anomalyco/opencode`: their flake cannot build their own CLI because `nix/node_modules.nix` prunes away the repository-root `script/` directory that `packages/cli/script/build.ts` imports
- [x] 6.2 Record a bean for checking `@tarquinen/opencode-dcp` and `@mohak34/opencode-notifier` against the v2 plugin API, which this change carries over unverified
