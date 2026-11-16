## 1. Flake input

- [x] 1.1 Add `atuin-threads-tui.url = "github:mipmip/atuin-threads-tui"` and `atuin-threads-tui.inputs.nixpkgs.follows = "nixpkgs"` to `flake.nix`
- [x] 1.2 Run `nix flake lock` and check that `flake.lock` gained the `atuin-threads-tui` node with its nixpkgs edge pointing at the root `nixpkgs`

## 2. Home Manager module

- [x] 2.1 In `modules/USERS/pim/programs/atuin.nix` add `inputs` to the outer argument set and `pkgs` to the `pim-atuin` argument set
- [x] 2.2 Add `inputs.atuin-threads-tui.packages."${pkgs.stdenv.hostPlatform.system}".default` to `home.packages`

## 3. Verification

- [x] 3.1 `nix build --impure .#homeConfigurations."pim@stinkie".config.home.path` and confirm `result/bin/att` exists
- [x] 3.2 `nix eval --impure --raw .#homeConfigurations."pim@harry".config.home.path` succeeds, so the aarch64-linux package resolves
- [ ] 3.3 On a host after `rme up_home`: `att` opens, lists the captured threads, and one thread shows its messages
- [x] 3.4 Confirm that a host without `pim-atuin` is unaffected: its `home.packages` does not grow
