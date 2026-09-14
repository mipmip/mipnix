Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 In `modules/programs/dev/infra/iac.nix`, add a `nivis-tunnel` wrapper
      to the existing `let` block, next to the `terraform` wrapper that already
      forwards to tofu:
      `nivis-tunnel = pkgs.writeShellScriptBin "nivis-tunnel" ''exec ${inputs.nivis-tunnel.packages."${pkgs.stdenv.hostPlatform.system}".tunnel}/bin/tunnel "$@"'';`
      The rename is the point: upstream ships `bin/tunnel` but documents every
      invocation as `nivis-tunnel`. Verify the file parses:
      `nix-instantiate --parse modules/programs/dev/infra/iac.nix`.
- [x] 1.2 Add that wrapper to `environment.systemPackages` in the same file,
      directly below the `nivis` entry so the two tools read as a pair.

## 2. Verification

- [x] 2.1 Build a devbox host and confirm the command lands under the right
      name: `nix build .#nixosConfigurations.doornappel.config.system.build.toplevel`,
      then `ls <toplevel>/sw/bin/nivis-tunnel` exists and
      `ls <toplevel>/sw/bin/tunnel` does not.
- [x] 2.2 Confirm it runs and forwards its arguments:
      `<toplevel>/sw/bin/nivis-tunnel --help` reaches the upstream program.
- [x] 2.3 Confirm the orchestrator-only scope: neither the agent nor the relay
      binary appears in `<toplevel>/sw/bin/`.
- [x] 2.4 Confirm the lock is unchanged. The `nivis-tunnel` input already exists
      from the durer relay change, so `git diff --stat flake.lock` is empty.

## 3. Note

- [x] 3.1 Recorded in the wrapper's own comment in `iac.nix`: if upstream renames `cmd/tunnel`'s binary to `nivis-tunnel`, or sets
      the package to install it under that name, this wrapper becomes dead
      weight and should be dropped for a plain package reference. nivis-tunnel
      is our own repository, so that is the durable fix; the wrapper is the
      local one that does not block on it.
