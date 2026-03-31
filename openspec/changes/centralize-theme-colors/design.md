## Context

Theme colors for active/inactive backgrounds are hardcoded in two places:
- `modules/user-pim/programs/tmux/default.nix` — `window-active-style bg=black` and `window-style bg='#292f32'`
- Neovim has no inactive window dimming yet, but should use the same inactive color

The tmux config is a home-manager module (has access to `config`). The mipvim package is built at flake level via `nixvim.makeNixvimWithModule` with `extraSpecialArgs = { }` — it cannot access home-manager options directly.

## Goals / Non-Goals

**Goals:**
- Single source of truth for shared theme colors (active/inactive background)
- Both tmux and neovim consume the same color values
- Neovim inactive windows (`NormalNC`) get the shared inactive background color
- Auto-discovered via import-tree under `modules/`

**Non-Goals:**
- Full theming system (font, accent colors, colorscheme selection)
- Replacing gruvbox or other colorscheme configuration
- Making colors configurable per-host or per-user (single set of defaults is fine for now)

## Decisions

### 1. Shared colors as a plain attrset file + home-manager module wrapper

A plain `colors.nix` attrset defines the actual values. A home-manager module in `modules/themes/` wraps it as `config.mip.theme.colors` options. The same `colors.nix` is imported directly into `flake.nix` for `extraSpecialArgs`.

**Why over pure home-manager options:** mipvim is a package, not a module. It can't read `config.mip.theme.colors` at build time. By having the colors in a plain importable file, both the HM module and flake.nix can reference the same values without circular dependencies.

**Why over just a plain file:** The HM module gives tmux (and future modules) idiomatic access via `config.mip.theme.colors`, and it's auto-discovered by import-tree.

### 2. Colors passed to nixvim via `extraSpecialArgs`

`flake.nix` imports the colors file and passes it as `extraSpecialArgs = { mipColors = import ./modules/themes/colors.nix; }`. Nixvim config files can then access `mipColors` as a module argument.

**Why:** This is the standard nixvim mechanism for injecting external data. No structural changes to how mipvim is built.

### 3. NormalNC highlight set via `extraConfigLua`

A one-line Lua snippet in the nixvim config sets the `NormalNC` highlight group using the color from `extraSpecialArgs`.

**Why over `dim_inactive`:** gruvbox's `dim_inactive` doesn't give control over the exact color, and with `transparent_mode = true` the result would be unpredictable. An explicit `NormalNC` highlight gives exact control and matches the tmux color precisely.

## Risks / Trade-offs

- **[Colors file is imported in two places]** → Acceptable: it's a pure attrset with no side effects. Both imports evaluate identically.
- **[Adding extraSpecialArgs changes nixvim module interface]** → Low risk: existing config files don't need to accept the new arg (Nix module system ignores unused args with `...`). Only the new highlight config will reference it.
