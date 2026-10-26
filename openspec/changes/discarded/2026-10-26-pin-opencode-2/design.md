## Context

See proposal.md for motivation. What decided the approach, all of it checked
against the v2 source tree and against real builds rather than against the docs:

- `modules/programs/dev/vibecoding/opencode.nix` sets `package =
  unstable.opencode` and a `settings` block in the v1 key names, plus `tui.theme
  = "system"`.
- The home-manager module `programs.opencode` (rev `e28654b7`) already carries
  `commands`, `agents`, `skills`, `tools`, `context` and `tui` options. Nothing
  about it blocks v2 except that `tui` now writes a file v2 has retired.
- `anomalyco/opencode` ships `flake.nix` with `packages.<system>.opencode` and
  `overlays.default`. Both call `nix/opencode.nix`, which takes `inherit
  (node_modules) version src`.
- `nix/node_modules.nix` builds `src` with `lib.fileset.unions [ ../packages
  ../services ../bun.lock ../package.json ../patches ../install
  ../.github/TEAM_MEMBERS ]`. The repository-root `script/` directory is absent
  from that list and present in the repository.
- `packages/cli/script/build.ts:15` reads `import { NativeArch } from
  "../../../script/native-arch"`, which resolves to that absent directory.
- The nixpkgs fork does not hit this, because it fetches the whole tree with
  `fetchFromGitHub` rather than pruning with a fileset.

## Goals / Non-Goals

**Goals:**

- opencode 2 from a tag of the upstream repository, pinned by the lock file.
- A build that works, with the reason for the workaround written down where the
  workaround is.
- Settings in the v2 schema, so no normalization diagnostic is logged at start.
- No nix-managed file where opencode expects to write.

**Non-Goals:**

- Sharing commands, context, rules or skills with Claude Code. That is the next
  change, and it depends on this one.
- Replicating the `prose-lint` PostToolUse hook as an opencode plugin.
- Verifying the two npm plugins against the v2 plugin API.
- Packaging `opencode-desktop`.
- Getting opencode 2 into nixpkgs.

## Decisions

### Pin upstream's flake, not the nixpkgs fork

The fork's branch name already lies about its contents, and a personal nixpkgs
tree is a larger thing to trust than a tagged release of the project itself.
Upstream's flake is the project's own build, which means a bump is a tag change
in the lock file.

The cost is the fileset bug below, and that the fork sets
`OPENCODE_DISABLE_AUTOUPDATE` while upstream does not.

### Fix the build by overriding `src`, not by vendoring

```nix
package =
  (inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode)
    .overrideAttrs (_: { src = inputs.opencode; });
```

`nix/opencode.nix` inherits `src` from the `node_modules` derivation. Replacing
it on the final derivation hands the build the unpruned flake source, which
contains `script/`. The fixed-output `node_modules` derivation keeps its own
pruned source, which is correct: `bun install` reads `bun.lock` and
`package.json` and has no use for `script/`.

Verified: `nix build` of the overridden package produces
`opencode-2.0.29+042d083` with `bin/opencode`, a `bin/opencode2` alias,
completions for bash, fish and zsh, `opencode --version` reporting
`v2.0.29+042d083`, and a wrapper adding ripgrep to `PATH` and wayland to
`LD_LIBRARY_PATH`.

Rejected alternatives:

- Vendoring the nixpkgs fork's `package.nix` into `packages/`. It works, but it
  means owning a build definition and a `node_modules` hash per bump, for a
  package that should come from nixpkgs eventually.
- Patching the fileset through an override of `node_modules`. That changes the
  fixed-output derivation, so the hash in upstream's `hashes.json` no longer
  applies and has to be recomputed per bump.
- Waiting for nixpkgs. nixos-unstable is on 1.19.0 and the upstream repository
  has moved owner, so this is not a near thing.

### Report the bug upstream

The override is a workaround for a defect in someone else's repository: their
flake cannot build their own CLI. Report it, so the override can be dropped
rather than carried forever.

### Let opencode own `cli.json`

v2's `packages/cli/src/config/migrate.ts` reads `<config>/tui.json` once, writes
`<config>/cli.json`, and from then on treats `cli.json` as its own. That already
happened on this machine: `~/.config/opencode/cli.json` exists with `theme.name
= "system"`, picked up from the store symlink home-manager wrote at `tui.json`.

So the theme is already carried across. Declaring `cli.json` from nix would make
the theme and the other in-application settings read-only, and changing them in
the TUI would fail against a store symlink. Dropping `programs.opencode.tui`
leaves the file where opencode put it.

The consequence worth stating: the TUI theme stops being declarative. That is
the trade v2 imposes, not one this change chooses.

### Do not follow nixpkgs

`mipnix-7txh` asks for inputs to follow this repository's nixpkgs. Following
here would build opencode against a bun other than the one upstream tests, for a
package that nothing caches either way. The input brings its own nixpkgs
(3181085, 2026-09-27), and the module carries a comment saying why.

## Risks / Trade-offs

- The build can break on any bump, from the fileset or from a new source
  requirement. Mitigation: the bump is gated by an actual `nix build`, and the
  override sits next to a comment explaining what it is for.
- `update = "disable"` means no update prompt. That is correct for a store
  install, where the binary cannot replace itself anyway.
- Carrying the two npm plugins unverified means a start-up error is possible. It
  is also the status quo, and checking them is its own piece of work.

## Open Questions

- Does `@tarquinen/opencode-dcp` or `@mohak34/opencode-notifier` still load
  under the v2 plugin API? Out of scope here, worth a bean.
