Schema source: https://github.com/speclib/openspec-tinychange-schema

The implementation landed before this spec correction, as a build fix: upstream
nivis-tunnel renamed `packages.tunnel` to `packages.nivis-tunnel` and now ships
`bin/nivis-tunnel`, which broke the wrapper written against the old name. The
wrapper is gone and `iac.nix` references the package directly. This change makes
the spec describe that world instead of the one it was written in.

## 1. Implementation

- [x] 1.1 Confirm the wrapper is gone from
      `modules/programs/dev/infra/iac.nix` and the package is referenced
      directly, so the spec and the code agree:
      `grep -c writeShellScriptBin modules/programs/dev/infra/iac.nix` returns 1
      (the terraform wrapper, which stays) and the nivis-tunnel entry reads
      `inputs.nivis-tunnel.packages."${pkgs.stdenv.hostPlatform.system}".nivis-tunnel`.

## 2. Verification

- [x] 2.1 Confirm the stale rationale is gone from the main spec after archive:
      `grep -c 'even though the package publishes' openspec/specs/nivis-tunnel-cli/spec.md`
      returns 0.
- [x] 2.2 Confirm the behaviour the spec describes still holds on a built host:
      `<toplevel>/sw/bin/nivis-tunnel` exists and resolves to the upstream
      binary rather than to a shell wrapper, and `tunnel`, `agent` and `relay`
      are absent.
