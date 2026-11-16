# Design

## Context

`att` is a Go/bubbletea TUI (`github.com/mipmip/atuin-threads-tui`, version
0.1.0). It does not open the SQLite database itself: `internal/atuin/client.go`
shells out to `atuin threads list|show|search --style json` and decodes the
reply. Any host that runs it therefore needs the `atuin` binary on `PATH`, and
`pim-atuin` already installs `unstable.atuin` through `programs.atuin` and sets
`threads.capture = true`, so the data is there.

The upstream flake exposes one package:

```nix
packages.default = pkgs.buildGoModule {
  pname = "att";
  version = lib.fileContents ./cmd/att/VERSION;   # 0.1.0
  src = lib.cleanSource ./.;
  subPackages = [ "cmd/att" ];
  vendorHash = null;                               # vendor/ is committed
  meta.mainProgram = "att";
};
```

Checked before writing this: `nix build github:mipmip/atuin-threads-tui` produces
`att-0.1.0` without changes, and `atuin threads list --style json` returns the
captured threads on this machine (atuin 18.24.5).

## Goals / Non-Goals

**Goals:** `att` on the `PATH` of every host that has atuin configured.

**Non-Goals:** a mipbar widget, a hotkey, changes to the atuin configuration,
and packaging `att` in `packages/`.

## Decisions

### External flake input, not a local package

`flake-structure` ("External Input Minimization") says a personally maintained
tool with its own release cycle is consumed as an input with a remote URI. The
input is referenced only by URI, so hosts without
`~/gh.mipmip/atuin-threads-tui` still build. Alternative: a local package under
`packages/`, which would need the source in this tree and would turn every
upstream fix into a source-tree edit.

```nix
atuin-threads-tui.url = "github:mipmip/atuin-threads-tui";
atuin-threads-tui.inputs.nixpkgs.follows = "nixpkgs";
```

### `nixpkgs.follows` on our 26.05 nixpkgs

Upstream pins nixos-unstable. Following our `nixpkgs` avoids a second nixpkgs in
the closure, and the build works there: 26.05 has Go 1.26.8 and `go.mod` asks
for 1.24.0. Alternative: let the upstream unstable pin come along, which costs
a whole extra nixpkgs evaluation for one small binary.

### Track the default branch, not the v0.1.0 tag

`github:mipmip/atuin-threads-tui` follows `main`, like the other
`mipmip/*` inputs (`dirty-repo-scanner`, `updo`, `nping`). Upgrading is
`nix flake update atuin-threads-tui`. If a release needs to be held, the URL can
become `github:mipmip/atuin-threads-tui/v0.1.0` without touching the module.

### The package line lives in `pim-atuin`

`att` is useless without the `atuin` binary, so the package and the thing it
reads sit in one module. `role-pim-cli-full` already imports `pim-atuin`, so
there is no role edit and no second place to keep in step. Alternative: a
separate `pim-att` module plus an import in `role-pim-cli-full`, which adds a
module whose only content duplicates a dependency that is already there.

### Direct package reference instead of an overlay

The module uses `inputs.atuin-threads-tui.packages."${pkgs.stdenv.hostPlatform.system}".default`,
the same shape as `pim-jjay` and `pim-hip`. An overlay would put `att` in `pkgs`
for every consumer, which nothing else needs.

## Risks / Trade-offs

- [The atuin JSON schema changes and `att` fails to parse it] -> `nix flake update` pulls the upstream fix; if upstream lags, pin the input to a tag.
- [An `att` build break on aarch64-linux blocks the Pi hosts] -> the package is pure Go and the upstream flake lists aarch64-linux; build harry-pi's profile before rolling out.
- [Upstream `vendorHash = null` assumes the committed `vendor/` matches `go.mod`] -> upstream runs `go test` in CI on every tag, and the build was verified from the GitHub revision.
- [Following 26.05 instead of unstable could lag on a future Go language version] -> currently built with Go 1.26.8; revisit if a flake update fails on the toolchain rather than the code.
