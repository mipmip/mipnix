## 1. Flake input

- [x] 1.1 In `flake.nix`, add `beandex.url = "github:mipmip/beandex";` (near the other `mipmip/*` inputs)

## 2. Home-manager module

- [x] 2.1 Create `modules/USERS/pim/programs/beandex.nix` exposing `flake.modules.homeManager.pim-beandex`
- [x] 2.2 Add the package: `home.packages = [ inputs.beandex.packages."${pkgs.stdenv.hostPlatform.system}".default ]`
- [x] 2.3 Write config: `xdg.configFile."beandex/config.yaml".text` with `scan_paths: [{ path: ~, max_depth: 2 }]`

## 3. tmux binding

- [x] 3.1 In `modules/USERS/pim/programs/tmux/default.nix`, add `bind D popup -E -w 90% -h 90% 'beandex'` to `extraConfig`

## 4. Role activation

- [x] 4.1 In `modules/ROLES/home-pim-cli-full.nix`, add `pim-beandex` to the homeManager imports (near `pim-huphop`)

## 5. Evaluation checks (pre-build)

- [x] 5.1 `nix flake lock` resolves the `beandex` input (→ d8578b4)
- [x] 5.2 `nix eval` `pim@cichorei` → `xdg.configFile."beandex/config.yaml"` renders `scan_paths: [{ path: ~, max_depth: 2 }]`
- [x] 5.3 `nix eval` the same host → `beandex` package present in `home.packages`; `bind D` present in rendered tmux config

## 6. Verification

- [x] 6.1 `nix build .#homeConfigurations."pim@cichorei".activationPackage` succeeds (beandex derivation builds)
- [x] 6.2 `beandex` package builds from the flake (`nix build github:mipmip/beandex`); config renders with `path: ~`, `max_depth: 2`
- [x] 6.3 tmux popup binding `bind D … 'beandex'` renders in the generated tmux config (live keypress confirmed on next home-manager switch)
