## Why

huphop is renamed to hip, and its repository moved to
https://github.com/mipmip/hip. The binary is now `hip`, the config lives in
`~/.config/hip`, and the token variable is `HIP_<PROVIDER>_TOKEN`. hip no
longer reads the old names, so the `huphop-tmux-switcher` spec describes a
setup that cannot work anymore.

## What Changes

- Replace the `huphop` flake input with `hip`, and the `pim-huphop`
  home-manager module with `pim-hip`.
- Generate the config at `~/.config/hip/config.yaml`, with
  `HIP_GITHUB_TOKEN` as the token variable.
- Rename the switch wrapper to `hip-tmux-switch`, and make `prefix + G` run
  `hip tui`.
- Move the requirements from `huphop-tmux-switcher` to a new
  `hip-tmux-switcher` capability. Behaviour stays the same.

## Capabilities

### New Capabilities

- `hip-tmux-switcher`: the requirements of `huphop-tmux-switcher`, under the
  new names.

### Modified Capabilities

- `huphop-tmux-switcher`: all requirements removed; the capability is
  replaced by `hip-tmux-switcher`.

## Impact

- `flake.nix`, `flake.lock`: input `huphop` becomes `hip`.
- `modules/USERS/pim/programs/hip/default.nix` (was `huphop/`),
  `modules/ROLES/home-pim-cli-full.nix`,
  `modules/USERS/pim/programs/tmux/binds.nix`, and two comments in
  `beandex.nix` and `smug_n_skull/default.nix`.
- Every host with `role-pim-cli-full` gets hip on its next `up_home`.
- The collections file is not migrated by Nix: `~/.config/hip` holds only
  the generated config until hip writes `collections.yaml` itself.
