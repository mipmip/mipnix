## 1. Flake input

- [x] 1.1 Add `nivis.url = "github:nivis-project/nivis";` and
      `nivis.inputs.nixpkgs.follows = "nixpkgs";` to the `inputs` block in
      `flake.nix`, grouped with the other personally-maintained tool inputs
      (`startaste`, `huphop`, `beandex`). Verify with
      `nix flake metadata --json | jq '.locks.nodes.nivis'` that the node exists
      and its `inputs.nixpkgs` is the followed path `["nixpkgs"]`, not a node id.
- [x] 1.2 Verify the `follows` actually saved a node: the lock must still hold
      31 distinct nixpkgs revisions across 32 nixpkgs nodes, unchanged from
      before this task. Compare against `git stash`ed `flake.lock` if in doubt.
- [x] 1.3 Verify the locked nivis revision builds on this repository's nixpkgs.
      Resolve that nixpkgs by FOLLOWING `nodes.root.inputs.nixpkgs`, never by
      indexing the node named `nixpkgs` — in this lock that name belongs to
      `agenix` (rev `59e69648`), while the root's is `nixpkgs_14` (`fcb8fcd6`).
      Building against the wrong one fails with `go.mod requires go >= 1.25.0`
      and looks like an upstream problem when it is a harness bug:
      `REV=$(python3 -c "import json;l=json.load(open('flake.lock'));n=l['nodes'];print(n[n['root']['inputs']['nixpkgs']]['locked']['rev'])")`
      then `nix build github:nivis-project/nivis/<locked-rev>#nivis
      --override-input nixpkgs github:NixOS/nixpkgs/$REV` succeeds and the
      result's `bin/nivis --version` prints a version.

## 2. Module wiring

- [x] 2.1 Add
      `inputs.nivis.packages."${pkgs.stdenv.hostPlatform.system}".nivis` to
      `environment.systemPackages` in `modules/programs/dev/infra/iac.nix`,
      beside `terraform` and `opentofu`. Take `inputs` from the module file's
      existing outer `{ inputs, ... }` argument — do not add `inputs` to the
      inner `{ config, pkgs, ... }` args (that is the `markdown.nix` shadowing
      mistake; follow `tui/tmux.nix` instead). Verify the file still parses with
      `nix-instantiate --parse modules/programs/dev/infra/iac.nix >/dev/null`.
- [x] 2.2 Verify the module evaluates in context: `nix eval --raw
      .#nixosConfigurations.<devbox-host>.config.system.build.toplevel.drvPath`
      succeeds for a host carrying `role-devbox`.

## 3. Verification

- [x] 3.1 Build a devbox host configuration end to end (`nixos-rebuild
      dry-build --flake .#<devbox-host>`, or `rme`/`RUNME.sh` equivalent) and
      confirm it completes without a new nixpkgs being fetched.
- [x] 3.2 Verify `nivis` resolves from the system profile with no `nix run` and
      no manual PATH entry. Checked against the built toplevel rather than by
      switching this machine (switching is the operator's step, per the
      ship-change.sh header): `<toplevel>/sw/bin/nivis` exists, resolves to
      `/nix/store/28xqkh55…-nivis-0.7.0/bin/nivis` — the same store path the
      pre-proposal spike produced — and reports `nivis 0.7.0`.
- [x] 3.3 Verify the CLI-only scope: `ls $(dirname $(readlink -f $(which
      nivis)))` lists `nivis` and neither `nivistutor` nor the
      `provider-alpha`/`provider-beta` fakes.
- [x] 3.4 Verify nivis starts without repository-managed configuration: run it
      on a host where it has never run and confirm it does not fail for a
      missing config file (the `beandex` failure mode this change explicitly
      avoids).
- [x] 3.5 Verify the upgrade path. Partially demonstrable at ship time: the
      lock's `original` for nivis is `{owner, repo, type}` with no `ref` and no
      `rev`, i.e. a moving reference that `nix flake update nivis` re-resolves;
      the run touched no file other than `flake.lock`. It could not be shown
      *advancing*, because upstream `main` HEAD is already the locked revision
      `d142ff5f` (which is also what the tag `v0.7.0` dereferences to). The
      no-edit half of the requirement is verified; the advance half is verified
      by construction and will be observable on the first upstream commit.

## 4. Bookkeeping

- [x] 4.1 Confirm `openspec validate add-nivis-cli --strict` passes with all
      four artifacts present.
- [ ] 4.2 On archive, record the archived path as `openspec-link` in the
      frontmatter of `.beans/mipnix-fjpq--*.md` and set its status to
      `completed`.
