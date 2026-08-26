## 1. Flake input

- [ ] 1.1 In `flake.nix`, add `beandex.url = "github:mipmip/beandex";` (near the other `mipmip/*` inputs)

## 2. Home-manager module

- [ ] 2.1 Create `modules/USERS/pim/programs/beandex.nix` exposing `flake.modules.homeManager.pim-beandex`
- [ ] 2.2 Add the package: `home.packages = [ inputs.beandex.packages."${pkgs.stdenv.hostPlatform.system}".default ]`
- [ ] 2.3 Write config: `xdg.configFile."beandex/config.yaml".text` with `scan_paths: [{ path: ~, max_depth: 2 }]`

## 3. tmux binding

- [ ] 3.1 In `modules/USERS/pim/programs/tmux/default.nix`, add `bind D popup -E -w 90% -h 90% 'beandex'` to `extraConfig`

## 4. Role activation

- [ ] 4.1 In `modules/ROLES/home-pim-cli-full.nix`, add `pim-beandex` to the homeManager imports (near `pim-huphop`)

## 5. Evaluation checks (pre-build)

- [ ] 5.1 `nix flake metadata` resolves the `beandex` input
- [ ] 5.2 `nix eval` a host using `cli-full` → `xdg.configFile."beandex/config.yaml"` renders the expected `scan_paths` YAML
- [ ] 5.3 `nix eval` the same host → `beandex` package present in the profile

## 6. Verification

- [ ] 6.1 `nixos-rebuild`/home-manager switch; `~/.config/beandex/config.yaml` exists with `path: ~`, `max_depth: 2`
- [ ] 6.2 `beandex` on PATH; running it lists repos with beans tickets (no config error)
- [ ] 6.3 In tmux, `prefix + D` opens the beandex popup at 90%×90%; `Enter` on a repo drops into `beans tui` and returns to the index on quit
