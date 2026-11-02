## Context

See `proposal.md` for the motivation. The current module builds OpenCode from
the `anomalyco/opencode` flake input and overrides the derivation's `src` because
the upstream flake's file set omits `script/native-arch`. That input is pinned to
`v2.0.29`. The `unstable` nixpkgs input already exists and is used across the
repository, but its lock predates official OpenCode 2.1.1.

The two plugin repositories are flakes. Their `packages.<system>.default` copies
`.opencode/plugins/<name>` into `$out/plugins/<name>` and performs no
compilation. The resulting directories are `beans-stats` and `openspec-stats`.
Both declare their own `nixpkgs` input on `nixos-unstable`.

## Goals / Non-Goals

**Goals:**

- One official OpenCode package, taken from the existing `unstable` input.
- Both plugins available in every project without per-project copies.
- Plugin revisions pinned in `flake.lock`, loaded from the Nix store, and updated
  only by an explicit flake update.
- Updating OpenCode and updating the plugins are independent operations.

**Non-Goals:**

- Changing the plugins themselves or their sidebar behavior.
- Fetching plugins from npm or GitHub at OpenCode startup.
- Automatically updating plugins or OpenCode.
- Migrating the other `pkgs-unstable` consumers as part of this change.
- Replacing the existing `opencode-dcp` and `opencode-notifier` plugins.

## Decisions

**Use the existing `unstable` input instead of a dedicated nixpkgs pin.** The
user already consumes `unstable` for many packages, so one nixpkgs source is
simpler than adding a second pin only for OpenCode. The cost is that the
OpenCode update arrives together with a broad unstable bump. A dedicated
`nixpkgs-opencode` input was considered and rejected because it adds another
full nixpkgs lock for a single package.

**Add the plugins as flake inputs instead of npm or git URLs.** A flake input
gives a store path that is pinned in `flake.lock`, works offline, and updates
with one `nix flake update` command. A runtime `plugins` entry pointing at a git
URL would fetch at startup and bypass the repository lock. Copying the plugin
directory into `~/.config/opencode/plugins` was rejected because it is a
user-managed copy that drifts from the flake.

**Make the plugin inputs follow the main `nixpkgs`.** The plugin packages only
copy files, so they do not need the newer `unstable` stdenv. Following the main
26.05 pin avoids a second nixpkgs lock inside each plugin input and keeps an
`unstable` bump from rebuilding them. Letting the plugins follow `unstable` was
considered, but it couples two independent update cadences.

**Pass the plugin directories through `programs.opencode.settings.plugins`.**
The setting accepts absolute paths, so the module can interpolate the assembled
store paths. This keeps the global configuration declarative and leaves no
files under `~/.config/opencode` for the user to manage. The existing npm
entries stay in the same list, so plugin order and behavior are preserved.

**Keep `update = "disable"`.** The store binary still cannot self-update. The
comment in the module must change from "updating is a tag change in flake.nix"
to "updating is `nix flake update unstable`".

## Risks / Trade-offs

- **The `unstable` bump moves many packages** -> Build the full home
  configuration and the affected package checks before switching. If a package
  breaks for an unrelated reason, pin `unstable` to a revision that carries
  OpenCode 2.1.1 and defer the rest of the bump.
- **Plugin API mismatch** -> The plugins declare `@opencode/plugin` 2.0.31 while
  the installed OpenCode is 2.1.1; the sidepanel README was tested with 2.0.29.
  Verify with `opencode plugin list`, open the TUI, and inspect the service log.
  If a plugin fails, pin its input to a known-good revision or patch it
  upstream; do not silently drop the plugin.
- **Global sidebars in unrelated projects** -> The sections show `unavailable`
  where `openspec/` or `.beans/` is absent. This is accepted because the user
  asked for global installation.
- **Plugin prerequisites** -> The Beans plugin expects `beans`, `openspec` and
  `jj` on `PATH`; all three are installed. OpenCode loads the TypeScript
  directly, so no Bun runtime is required.
- **The paused `add-opencode-go-usage` change** wraps the old
  `inputs.opencode` derivation. It must be rebased on the official package
  before it is applied; this change does not implement it.

## Migration Plan

1. Run `nix flake update unstable` and confirm the input provides OpenCode 2.1.1.
2. Add the two plugin inputs to `flake.nix`, both with
   `inputs.nixpkgs.follows = "nixpkgs"`, and remove the `opencode` input and its
   comment block.
3. In `modules/programs/dev/vibecoding/opencode.nix`, replace the let-bound
   OpenCode package with `inputs.unstable.legacyPackages.${system}.opencode`.
4. Append the two assembled plugin directories to
   `programs.opencode.settings.plugins`, using
   `inputs.opencode-beans.packages.${system}.default` and the sidepanel
   equivalent.
5. Update the `update = "disable"` comment to point at `nix flake update
   unstable`.
6. Build the home configuration, switch, run `opencode service restart`, and
   verify `opencode --version` and `opencode plugin list` in a project with and
   without `openspec/` and `.beans/`.
7. Run a plugin update with
   `nix flake update opencode-beans opencode-openspec-sidepanel`, switch, and
   confirm only the plugin paths change.

Rollback is a revert of `flake.nix`, `flake.lock` and the module, followed by a
home-manager switch and `opencode service restart`. The old anomalyco input
remains in git history.
