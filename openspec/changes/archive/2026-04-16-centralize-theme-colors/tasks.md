## 1. Shared Colors Definition

- [x] 1.1 Create `modules/themes/colors.nix` as a plain attrset with `bg.active = "#000000"` and `bg.inactive = "#292f32"`
- [x] 1.2 Create `modules/themes/default.nix` as a home-manager module that exposes `config.mip.theme.colors` options with defaults from `colors.nix`

## 2. Nixvim Integration

- [x] 2.1 Update `flake.nix` to import `colors.nix` and pass it as `mipColors` in `extraSpecialArgs`
- [x] 2.2 Add nixvim config file for `NormalNC` highlight using `mipColors.bg.inactive` from `extraSpecialArgs`

## 3. Tmux Integration

- [x] 3.1 Update `modules/user-pim/programs/tmux/default.nix` to read `config.mip.theme.colors.bg.active` and `config.mip.theme.colors.bg.inactive` instead of hardcoded hex values
