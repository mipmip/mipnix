---
# mipnix-fjpq
title: make the nivis CLI available alongside terraform and tofu
status: in-progress
type: feature
priority: normal
tags:
    - nix
    - iac
created_at: 2026-09-14T13:57:52Z
updated_at: 2026-09-14T14:10:17Z
---

Ship the `nivis` CLI (github.com/nivis-project/nivis — my own "experimental
terraform nix mariage") as part of the devbox toolchain, next to terraform,
opentofu and the rest in `modules/programs/dev/infra/iac.nix`.

Upstream is already a well-formed flake, so no packaging work is needed: it
exposes `packages.<system>.nivis` (a buildGoModule CLI, version from its
VERSION file) for all three systems mipnix builds. Adding it is a flake input
plus one entry in `environment.systemPackages`, the same shape as `inputs.mip`
in desktop/apps/markdown.nix and `inputs.skull` in tui/tmux.nix.

Decisions taken up front:

- **CLI only.** The flake also exposes `tutor` (the tutorial scaffolder) and
  `fake-providers`; neither ships here.
- **No configuration.** Nivis needs nothing in ~/.config today. When it grows
  config, that becomes its own change (cf. the beandex config.yaml pattern).
- **`nivis.inputs.nixpkgs.follows = "nixpkgs"`** so it builds against mipnix's
  26.05 instead of dragging in a 32nd nixpkgs revision. Verify the Go build
  actually holds on 26.05 before committing to it.
- **Moving ref, not a pinned tag.** `nix flake update nivis` must pull the
  newest version, which a `v0.x.y` ref can never do. Open question for the
  proposal: track `main` (bleeding edge, may run ahead of the last release), or
  have upstream maintain a `stable` branch that fast-forwards to each new tag
  so mipnix always lands on a released version.

Scope note: iac.nix is a NixOS module reached via role-devbox, so this is
linux-only. If nivis needs to follow me to darwin later, that is a move to a
`pim-nivis` home-manager module, not part of this.
