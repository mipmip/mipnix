## Why

Keybindings are declared in six unrelated places and documented in a seventh
that is a hand-written copy. `modules/USERS/pim/programs/myhotkeys/myhotkeys.json`
lists 13 Hyprland bindings against the 66 in `hypr/binds.conf`, and 1 tmux
binding against the 14 in the tmux module's own registry. Every binding added
since that file was last touched is invisible in the cheatsheet, and nothing
catches the drift.

The tmux module already solved this for one target: `customBinds` in
`modules/USERS/pim/programs/tmux/default.nix` is declared once and emitted twice,
as `bind` lines and as the `prefix + ?` menu, with a build-time guard against
values tmux cannot render. This change lifts that pattern to a flake-wide
registry and points every binding-producing and binding-documenting consumer at
it.

## What Changes

- Add `flake.hotkeys`, a merged registry contributed from any module, following
  the `flake.nebulaNodes` precedent in
  `modules/services/networking/nebula-nodes-option.nix`.
- Model entries as five kinds, because a keybinding is not one shape: `chord`
  (absolute modifier combination), `prefixed` (tmux prefix plus key), `mapped`
  (editor mode plus lhs), `word` (a typed alias or abbreviation), and `sequence`
  (in-application multi-key, documentation only).
- Canonicalise the key in X11 keysym terms and render it per target. The action
  stays in target-native syntax and is passed through verbatim, since a Hyprland
  dispatcher, a tmux command and a Lua callback have nothing in common.
- Generate the configuration for the targets this repository owns:
  `hypr/binds.conf` (today a static 143-line file), the tmux `bind` lines and
  `prefix + ?` menu, fish aliases and abbreviations, ghostty `keybind` entries,
  and the gnome `dconf` keybinding settings.
- Project, rather than re-author, the sources that already carry key plus
  description in Nix: the 548-line nixvim `keymaps` list in
  `packages/mipvim/config/keymaps.nix` keeps its current form and contributes to
  the registry through a derived view.
- Carry documentation-only entries for applications this repository does not
  configure (zathura, gimp, inkscape, firefox, readline, sc-im, claude code) and
  for shell words defined elsewhere, such as the `g*` git abbreviations.
- Generate `~/.config/myhotkeys/keys.json` from the registry instead of shipping
  a hand-maintained file. **BREAKING** for that file: it stops being editable by
  hand, and entries not represented in the registry are dropped.
- Package `keyb` (github.com/kencx/keyb, MIT, v0.8.0), which is not in nixpkgs,
  as an overlay entry alongside the existing `clear-sans` case in
  `modules/nix/overlays/`.
- Generate the keyb hotkey file from the registry and bind a tmux key that opens
  keyb in a popup. The key is context aware: the wrapper inspects
  `#{pane_current_command}` and passes the matching generated file through
  keyb's `-k` flag, so an nvim pane opens the nvim sheet and any other pane
  opens the full one.
- Keep `prefix + ?` as the actionable `display-menu` it is today. keyb lists
  command selection as an explicit non-feature, so replacing the menu with it
  would trade an action for a lookup. The two live side by side on separate
  keys.

## Capabilities

### New Capabilities

- `hotkey-registry`: the `flake.hotkeys` option, the five entry kinds, the
  canonical key model and its per-target renderers, scope tagging, and the
  build-time validation that rejects entries a target cannot express.
- `hotkey-config-emission`: generation of the owned configuration from the
  registry for Hyprland, tmux, fish, ghostty and gnome, and the projection of
  the existing nixvim keymaps into the registry.
- `hotkey-cheatsheet-files`: generation of the keyb hotkey file and the
  myhotkeys `keys.json`, including which entries each viewer receives and how
  the per-context keyb files are split.
- `keyb-tmux-popup`: packaging keyb and the tmux binding that opens it in a
  popup with the file chosen from the current pane's command.

### Modified Capabilities

- `tmux-bind-registry`: the module-local `customBinds` list becomes a view of
  `flake.hotkeys` filtered to the tmux target, and a second key is added for the
  keyb popup. The `prefix + ?` menu, its grouping, its accelerators and its
  escaping rules are unchanged in behaviour.

## Impact

Configuration replaced by generated output:

- `modules/USERS/pim/programs/hyprland/hypr/binds.conf` (66 binds across `bind`,
  `bindel` and `bindm`, no submaps)
- `modules/USERS/pim/programs/myhotkeys/myhotkeys.json` (deleted)
- `modules/USERS/pim/programs/tmux/default.nix` (`customBinds` let-binding)
- `modules/USERS/pim/shared/shell-aliases.nix` (`shared.shellAliases`, an
  `attrsOf str` with no descriptions today)
- `modules/USERS/pim/programs/ghostty.nix` (`keybind` list)
- `modules/USERS/pim/_gnome/desktop-shortcuts.nix` (`dconf.settings`
  keybinding sections)
- `packages/mipvim/config/keymaps.nix` (read, not rewritten)

New:

- a registry option module and a renderer library under `lib/`
- a `keyb` overlay entry and its addition to `modules/nix/channels.nix`
- the keyb popup launcher script in the tmux module

Constraints:

- `flake.hotkeys` is evaluated before `pkgs`, so entries hold plain strings
  only. No store paths in the registry.
- Generating `binds.conf` moves the explanatory comments in it (hyprlock
  fallback, screenshot notification behaviour) into the registry. The generator
  has to emit them, or that reasoning stops shipping to the file read when
  debugging Hyprland.
- Around 200 emitted entries plus the documentation-only set, so the generated
  output has to stay diffable against the current files during the switch.
