## Why

`vibecoding-opencode` installs `unstable.opencode`, which is 1.18.25 at the
current `unstable` pin and 1.19.0 on today's nixos-unstable. opencode 2 is not
in nixpkgs at all. It has been run here by hand instead:

```
nix run github:shamil2/nixpkgs/opencode-2.0.22#opencode
```

That is a personal nixpkgs fork whose branch is named after a version it no
longer carries: `opencode-2.0.22` builds 2.0.29. Pinning to it means trusting a
moving branch in a third-party tree.

opencode 2 is also not a version bump. The project moved from `sst/opencode` to
`anomalyco/opencode`, renamed most of the config keys this repository sets, and
replaced `tui.json` with a `cli.json` that opencode writes itself. The present
module is wrong about all three, and only keeps working because v2 migrates
legacy keys and logs a diagnostic for each one at every start.

This pins opencode to a tag of the upstream repository, which ships its own
flake, and brings the configuration up to the v2 schema.

## What Changes

- Add `opencode` as a flake input pinned to a tag of `anomalyco/opencode`, and
  take `packages.<system>.opencode` from it instead of `unstable.opencode`.
- Override `src` on that package with the unpruned flake source. Upstream's
  `nix/node_modules.nix` prunes the source with a fileset that omits the
  repository-root `script/` directory, while `packages/cli/script/build.ts`
  imports `../../../script/native-arch`, so the upstream flake cannot build its
  own CLI without this. Verified against `v2.0.29` and against `main` (2.0.30).
- Do not make the input follow this repository's `nixpkgs` or `unstable`.
  Upstream pins nixpkgs-unstable for the bun version its build is tested
  against, and the build is uncached either way, so following buys nothing and
  risks the build.
- Rename the settings to the v2 schema: `autoshare` to `share`, `autoupdate` to
  `update`, `plugin` to `plugins`, `provider` to `providers`.
- Set `update = "disable"`. Upstream's wrapper, unlike the nixpkgs one, does not
  set `OPENCODE_DISABLE_AUTOUPDATE`, and the present `autoupdate = true`
  migrates to `update: "auto"`, which asks a store-installed binary to replace
  itself.
- Stop managing `tui.json`. v2 reads it once as legacy input, writes
  `~/.config/opencode/cli.json`, and then owns that file, so a read-only store
  symlink there would break the in-application settings.

## Capabilities

### New Capabilities

- `opencode-provisioning`: how opencode is pinned and built on this machine, the
  source override its upstream flake requires, the configuration this repository
  declares, and the configuration it deliberately leaves to opencode itself.

## Impact

- `flake.nix`, one input.
- `modules/programs/dev/vibecoding/opencode.nix`, the package and the settings.
- No change to `claude.nix`: sharing commands, context and rules between the two
  agents is a separate change that depends on this one.

Constraints:

- The `src` override is load-bearing, not cosmetic: without it the pin does not
  build. It has to be re-tested on every version bump, because upstream may fix
  the fileset and make it redundant.
- Upstream's `node_modules` derivation name embeds `self.shortRev`, so every tag
  bump rebuilds the fixed-output `node_modules` even when `bun.lock` did not
  change.
- The build is uncached and takes minutes: a `bun install` and a bun compile
  with `--max-old-space-size=4096`.
- `mipnix-7txh` wants this repository's flake inputs to follow its nixpkgs. This
  input is a deliberate exception, and the module says so.
- The two npm plugins this configuration loads, `@tarquinen/opencode-dcp` and
  `@mohak34/opencode-notifier`, are carried over unchanged. v2 reworked the
  plugin hook names, so whether they still function is unverified and out of
  scope here.
