---
# mipnix-7txh
title: make my own flake inputs follow mipnix nixpkgs
status: todo
type: task
tags:
    - nix
created_at: 2026-09-14T14:01:49Z
updated_at: 2026-09-14T14:01:49Z
---

flake.lock currently carries 32 nixpkgs nodes across 31 distinct revisions —
almost no sharing at all. 13 inputs already declare
`inputs.nixpkgs.follows`; 19 still drag in a nixpkgs of their own.

The cost is not the 1945-line lockfile. It is that every tool built against its
own nixpkgs gets its own glibc and its own Go/Rust toolchain, so none of it
shares a closure with the system I already build — and every `nix flake update`
fetches and evaluates 19 extra package sets.

Add `follows = "nixpkgs"` where it is safe. Not as one sweep: each input moves
off the nixpkgs its own CI validated, so breakage lands at rebuild time here
instead of upstream. Build each one before committing it.

Three buckets:

- **Do**: mip, teejay, skull, rme, beandex, huphop, verynix, specgetty,
  dirty-repo-scanner, jsonify-aws-dotfiles, hypr-network-manager, jjay. My own
  Go/Rust CLIs; their vendorHash/cargoHash is nixpkgs-independent, so the risk
  is limited to toolchain drift.
- **Careful**: myhotkeys. Crystal, deliberately pinned at tag 0.2.7 — Crystal
  version drift is a genuine breaker. Only if it builds clean on 26.05.
- **Leave alone**: home-manager-pine64, agenix, bmc, race, fred, aoe. Either a
  deliberate old pin (pine64 is on 22.05) or not mine to vouch for.

Ordered after mipnix-fjpq (nivis), which is purely additive — this one is the
change that can break twelve rebuilds at once.
