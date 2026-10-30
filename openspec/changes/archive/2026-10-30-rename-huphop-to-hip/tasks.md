## 1. Flake and modules

- [x] 1.1 Replace the `huphop` input with `hip.url = "github:mipmip/hip"` and relock.
- [x] 1.2 Move `programs/huphop` to `programs/hip`; rename the module to `pim-hip` and update `home-pim-cli-full.nix`.
- [x] 1.3 Generate `~/.config/hip/config.yaml` with `auth.env = "HIP_GITHUB_TOKEN"`.
- [x] 1.4 Rename the wrapper to `hip-tmux-switch` and point `prefix + G` at `hip tui`.
- [x] 1.5 Update the remaining huphop mentions in `beandex.nix` and `smug_n_skull/default.nix`.

## 2. Verify

- [x] 2.1 Build the delliebellie home configuration; it contains `bin/hip` and `.config/hip/config.yaml`.
- [x] 2.2 Apply with `rme up_home`; `hip` is on the PATH and `hup` is gone.
- [x] 2.3 Run `hip config check`; it reports the config as valid.

## 3. Specs

- [x] 3.1 Archive this change with `retire_capabilities: true`, which deletes the `huphop-tmux-switcher` spec.
