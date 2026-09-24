## 1. Registry foundation

- [x] 1.1 Add `modules/hotkeys/option.nix` declaring `options.flake.hotkeys` as a `listOf submodule` with the kind-tagged schema from design.md, and verify `nix eval .#hotkeys` returns an empty list on a flake with no contributors
- [x] 1.2 Add the kind discriminator and per-kind required fields to the submodule, and verify an entry missing `desc` fails `nix eval .#hotkeys` with a message naming the entry
- [x] 1.3 Add the canonical keysym allowlist and the modifier set to a renderer library under `flake.lib.hotkeys`, and verify an entry with key `Enter` fails the build naming the unrecognised key while `Return` evaluates
- [x] 1.4 Add modifier-order normalisation, and verify that `[ "shift" "super" ]` and `[ "super" "shift" ]` render identically
- [x] 1.5 Add duplicate detection scoped per target, and verify two Hyprland entries on `Super+W` fail the build naming both while a Hyprland `Super+W` and a tmux `W` coexist
- [x] 1.6 Port the tmux syntax rules (leading `-`, apostrophe, `;` escaping) into the shared validator as target-conditional rules, and verify an apostrophe fails for a tmux entry and passes for a Hyprland one
- [x] 1.7 Verify the registry evaluates without a package set by reading it from a context with no `pkgs` in scope, matching the `flake.lib.nebulaHosts` constraint

## 2. Renderers

- [x] 2.1 Implement the chord renderers for hyprland, gnome, myhotkeys, ghostty and keyb, and verify `mods=[super shift] key=Return` produces `$mainMod SHIFT, RETURN`, `<Shift><Super>Return`, `<SHIFT><SUPER>Return`, `super+shift+enter` and a Super/Shift/Return combination respectively
- [x] 2.2 Add the ghostty keysym alias table, and verify `Return` renders as `enter` and `space` renders as ghostty's own spelling
- [x] 2.3 Implement the `prefixed`, `mapped`, `word` and `sequence` renderers, and verify a `sequence` entry of `y y` is emitted verbatim with no modifier rendering applied
- [x] 2.4 Implement the selectors `forTarget`, `forScope` and `byApp`, and verify an entry with no scope is returned by every scope query
- [x] 2.5 Verify an entry with `target = null` is returned by no `forTarget` query and by every cheatsheet query

## 3. Migrate the existing documentation

- [x] 3.1 Transcribe every group in `modules/USERS/pim/programs/myhotkeys/myhotkeys.json` into registry entries, using `target = null` for applications this repository does not configure, and verify all 13 groups are represented
- [x] 3.2 Implement the myhotkeys `keys.json` generator and write it through `home.file`, and verify the generated file parses as JSON and matches the current file except for ordering
- [x] 3.3 Verify a `word` entry renders into the `command` field of `keys.json` and a `chord` entry into the `key` field

## 4. tmux target

- [x] 4.1 Move the 14 entries in the `customBinds` let-binding of `modules/USERS/pim/programs/tmux/default.nix` into the registry with `target = "tmux"`, and verify the module holds no list of bindings afterwards
- [x] 4.2 Rewrite the `bind` line and menu emitters to read `forTarget "tmux"`, and verify the generated `.tmux.conf` section is byte-identical to the one generated today
- [x] 4.3 Run `./RUNME.sh up_home` and `./RUNME.sh reload_tmux`, then verify every existing key still runs its command and `prefix + ?` shows the same entries in the same groups with the same separator
- [x] 4.4 Verify `beans-tui-popup`, `nebula-ssh` and `drs-switch` are unmodified by the change

## 5. Hyprland target

- [x] 5.1 Transcribe all 66 binds from `modules/USERS/pim/programs/hyprland/hypr/binds.conf` into registry entries, carrying the `bind`, `bindel` and `bindm` variants and the existing explanatory comments as `note` fields, and verify the entry count matches the file
- [x] 5.2 Implement the Hyprland generator emitting `$mainMod` unexpanded and `note` fields as comments above their bind lines, and verify the lock and suspend reasoning appears in the generated file
- [x] 5.3 Replace the static `binds.conf` with the generated file, and verify a normalised sorted diff against the previous file shows no binding added, removed or changed
- [x] 5.4 Rebuild with `./RUNME.sh up_machine`, reload Hyprland, and verify a sample across the variants still works: `Super+Return`, `Super+Q`, a `bindel` volume key and a `bindm` mouse binding

## 6. Shell target

- [x] 6.1 Move `shared.shellAliases` into `word` registry entries with descriptions, and verify the generated fish aliases resolve to the same commands as today
- [x] 6.2 Add the `g*` git abbreviations from `myhotkeys.json` as documentation-only `word` entries, and verify no fish alias is created for them
- [x] 6.3 Open a new shell and verify every alias defined today still resolves, including `tmxa`, `tmxb`, `crb_mount` and the `smugs*` set

## 7. ghostty and gnome targets

- [x] 7.1 Move the ghostty `keybind` list into the registry and generate it, and verify the generated configuration contains `ctrl+shift+c=copy_to_clipboard` and `ctrl+shift+v=paste_from_clipboard`
- [x] 7.2 Add an unbind representation for gnome entries, and verify an unbinding emits an empty list and is absent from the cheatsheets
- [x] 7.3 Move the keybinding sections of `modules/USERS/pim/_gnome/desktop-shortcuts.nix` into the registry and generate the dconf settings, and verify the generated settings match the current ones key for key

## 8. neovim projection

- [x] 8.1 Add the projection that imports `packages/mipvim/config/keymaps.nix` and maps keymaps carrying `options.desc` to `mapped` entries, and verify the projected count equals the number of keymaps with a description
- [x] 8.2 Verify a keymap without a description is dropped without failing the build
- [x] 8.3 Edit one keymap's description, rebuild, and verify the cheatsheet reflects it with no second edit
- [x] 8.4 Verify `packages/mipvim/config/keymaps.nix` is unmodified by this change

## 9. keyb package and cheatsheet files

- [x] 9.1 Add a `keyb` `buildGoModule` derivation at the pinned upstream tag to a new `modules/nix/overlays/tools.nix`, register it in `modules/nix/channels.nix`, and verify `keyb --version` reports the pinned release
- [x] 9.2 Implement the keyb file generator producing one section per application, and verify the generated file loads in keyb with every section present
- [x] 9.3 Generate the per-application keyb files alongside the full one into `~/.config/keyb/`, and verify a file exists for each application that has its own entries
- [x] 9.4 Verify tmux entries render their key prefix-relative and that no keyb section carries a `prefix:` field
- [x] 9.5 Verify the generated cheatsheet lists the bindings the hand-written file omits, among them `Super+Space`, `Super+A`, `Super+Tab`, `Ctrl+Shift+E` and every custom tmux binding

## 10. keyb tmux popup

- [x] 10.1 Add the `keyb-popup` launcher mapping a pane command to its generated file with a fallback to the full one, and verify it prints the full file path for an unknown command
- [x] 10.2 Register the popup binding in the registry with `#{pane_current_command}` passed as an argument on the bind line, and verify the entry appears in the `prefix + ?` menu
- [x] 10.3 Verify the popup opens the neovim sheet from a pane running neovim and the full sheet from a shell pane
- [x] 10.4 Verify firing the keyb entry from the `prefix + ?` menu opens the popup, and that `prefix + ?` still executes the highlighted command on Enter
- [x] 10.5 Verify the full cheatsheet is reachable when the popup has opened a per-application sheet

## 11. Cleanup and verification

- [x] 11.1 Delete `modules/USERS/pim/programs/myhotkeys/myhotkeys.json` and verify the module ships the generated file instead
- [x] 11.2 Verify no hand-written list of bindings remains in any of the six migrated modules
- [x] 11.3 Verify a target with every entry removed produces an empty valid configuration and does not fail the build
- [x] 11.4 Add one new binding to the registry, rebuild, and verify it appears in the target's configuration, the `prefix + ?` menu where applicable, the keyb cheatsheet and `keys.json` with no other file edited
- [x] 11.5 Run a full `./RUNME.sh up_machine` on one host and verify Hyprland, tmux, fish, ghostty, neovim and both cheatsheet viewers all start with their bindings intact
