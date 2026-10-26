## Context

The repo migrated from a flat `hosts/<name>/` layout to the dendritic
`modules/HOSTS/<name>/` layout (flake-parts). During that migration the
`new_host` / IP-allocation helpers were updated to the new paths (captured by the
`host-scaffolding` spec), but the trailing "Next steps" message inside
`new_nebula_node` (`RUNME.d/nebula.sh`) was missed. It still tells operators to
edit `hosts/$NODE_NAME/nebula.nix` — a directory and file that no longer exist.

Everything `new_nebula_node` actually executes is still correct:

- Certificates are written to `secrets/nebula-<node>.crt.age` / `.key.age`.
- `secrets/secrets.nix` is edited with a `sed` insert of
  `"nebula-<node>.*.age".publicKeys = users ++ systems;` before the closing `}`.
  `users` and `systems` are still defined, existing nebula entries use that exact
  form, and the first bare `}` line is the real closing brace, so the insert lands
  correctly.

The nebula implementation itself (node naming, per-host wiring, the shared
module) has never been spec'd; the correct pattern lives only in example files
like `modules/HOSTS/durer-server/networking.nix` and
`modules/services/networking/nebula.nix`.

## Goals / Non-Goals

**Goals:**
- Make the on-screen guidance from `new_nebula_node` match the `modules/HOSTS/`
  layout and the real wiring pattern.
- Capture the already-correct provisioning behavior and the nebula nix
  implementation as specs so they stop being tribal knowledge.

**Non-Goals:**
- No change to certificate contents, signing, encryption recipients, IP
  allocation logic, or mesh runtime behavior.
- No refactor of the host wiring or the shared nebula module — this change
  documents them as-is and only corrects guidance text.
- Not auto-generating the host's `networking.nix`; wiring stays a manual,
  guided step.

## Decisions

**Decision: Fix only the guidance text, keep the functional flow untouched.**
The diagnosis showed the cert generation and `secrets.nix` edit are structurally
compatible. Rewriting more than the message would risk regressions for zero
benefit. Alternative considered: auto-scaffold the host `networking.nix` snippet
— rejected as scope creep and because host modules vary (firewall, hostname,
extraHosts) and are better authored from the `durer-server` template.

**Decision: Two capabilities, not one.**
`nebula-node-provisioning` covers the RUNME.d tooling (what the operator runs);
`nebula-mesh-networking` covers the nix implementation (what the mesh is). They
have different audiences and change cadence, and splitting keeps each spec
focused. Alternative considered: a single `nebula` spec — rejected as it would
mix shell-tool behavior with nix module structure.

**Decision: Point guidance at `modules/HOSTS/durer-server/networking.nix` as the
canonical template.** It is a current, minimal, correct example of the
`age.secrets` + `services.nebula.networks.mesh` pattern using
`nebula-${hostname}`.

## Risks / Trade-offs

- [Spec drift if the wiring pattern later changes] → The specs describe the
  pattern at a behavioral level (secret names, owner, mesh cert/key references)
  rather than pinning exact line numbers, so ordinary edits won't invalidate them.
- [Guidance references a specific example host that could be renamed/removed] →
  Phrase it as "an existing nebula host such as `durer-server`" so the guidance
  degrades gracefully rather than hard-depending on that host.
- [`sed` insert relies on the first bare `}` being the closing brace] → Verified
  true today; documented in the spec as an invariant so future edits to
  `secrets.nix` structure are made with it in mind.
