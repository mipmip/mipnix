## Why

The `new_nebula_node` RUNME.d command still prints post-creation guidance that
references a repository layout that no longer exists (`hosts/<node>/nebula.nix`),
so anyone following it after generating certificates is sent to a path and file
that were removed when the repo moved to the dendritic `modules/HOSTS/` layout.
The nebula implementation as a whole also has no spec coverage, so the correct
wiring pattern and node-naming convention live only in tribal knowledge and
example files.

## What Changes

- Correct the `new_nebula_node` "Next steps" message so it points at the real
  layout: `modules/HOSTS/<host>/networking.nix`, the dendritic
  `flake.modules.nixos.<name>` pattern, `age.secrets` for
  `nebula-${hostname}-key`/`-cert`, and `services.nebula.networks.mesh.cert/key`.
- Document (spec-only, no code change) the invariant functional behavior of
  `new_nebula_node` that is already correct: certificate file naming, the
  `secrets/secrets.nix` `publicKeys = users ++ systems` registration, and nebula
  IP allocation.
- Document the nix-side nebula implementation: the node-naming convention (short
  node name = certificate name = `hostname` variable, distinct from the suffixed
  host directory), the per-host wiring pattern, and the shared nebula module.

No runtime behavior of the generated certificates or the mesh changes; the only
executable change is corrected on-screen guidance text.

## Capabilities

### New Capabilities
- `nebula-node-provisioning`: the `new_nebula_node` RUNME.d command — certificate
  generation, `secrets.nix` registration, nebula IP allocation, and accurate
  post-creation guidance that matches the `modules/HOSTS/` layout.
- `nebula-mesh-networking`: the nix-side nebula implementation — node-naming
  convention, per-host wiring (`age.secrets` + `services.nebula.networks.mesh`),
  and the shared nebula module providing the CA certificate and sshd host key.

### Modified Capabilities
<!-- None. The corrected guidance text has no existing spec; it is captured by the
     new nebula-node-provisioning capability rather than modifying another spec. -->

## Impact

- **Code**: `RUNME.d/nebula.sh` (the `new_nebula_node` "Next steps" gum message).
- **Specs**: adds `nebula-node-provisioning` and `nebula-mesh-networking`.
- **Docs/behavior**: aligns operator guidance with `modules/HOSTS/`; complements
  the existing `host-scaffolding` and `agenix-rekey-helper` specs, which already
  cover `new_host` path usage and the shared age-identity helper respectively.
- No change to certificate contents, encryption recipients, or mesh runtime.
