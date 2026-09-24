## Context

See proposal.md for motivation. The constraints that shape the approach:

- The repository is dendritic flake-parts. A flake-level option contributed from
  many files already exists as a pattern:
  `modules/services/networking/nebula-nodes-option.nix` declares
  `options.flake.nebulaNodes`, hosts write into it, and `flake.lib.nebulaHosts`
  in `modules/nix/helpers.nix` derives a view that the tmux module consumes.
  This change is the same shape at a larger scale.
- `flake.lib` is evaluated with `{ inputs, lib, self, ... }` and no `pkgs`. The
  comment on `nebulaHosts` records why that matters: it reads literal strings
  only, so it does not pull in `nixosConfigurations` and does not recurse
  through `inputs.self`. The hotkey registry inherits that constraint.
- The six binding sources are not symmetric. Two are already structured Nix with
  descriptions (`packages/mipvim/config/keymaps.nix`, 548 lines with
  `options.desc`), two are structured Nix without descriptions
  (`shared.shellAliases`, gnome `dconf.settings`), one is a structured Nix list
  with descriptions that is already a registry (tmux `customBinds`), and one is
  a static text file (`hypr/binds.conf`, 66 binds).
- keyb accepts a hotkey file path (`-k`) and has no filter flag. That single
  fact decides how context awareness is built.

## Goals / Non-Goals

**Goals:**

- One declaration per binding, reachable from NixOS modules, home-manager
  modules and the neovim configuration alike.
- The key is translated, the action is not.
- A binding that exists today keeps working, and the move is verifiable rather
  than asserted.
- Documentation-only entries are as cheap to add as a line of data, because that
  is the class that grows fastest.

**Non-Goals:**

- Parsing any application's own configuration format. Nothing reads
  `binds.conf`, `.tmux.conf` or a dotfile to discover bindings.
- Runtime discovery of bindings. Everything is known at build time.
- Making keyb able to execute a binding. It stays a reader.
- A general key-conflict solver across targets. Duplicate detection is per
  target, because `Super+W` in Hyprland and `W` after the tmux prefix do not
  collide.

## Decisions

### The registry is `flake.hotkeys`, a list of submodules

Declared in a single option module, `modules/hotkeys/option.nix`, as
`lib.types.listOf (lib.types.submodule ...)`. A `listOf` concatenates across
modules, so any file can append without coordination, the same way hosts append
to `flake.nebulaNodes`.

Rejected: a home-manager option such as `mip.hotkeys`. The neovim configuration
and any NixOS-level consumer cannot see home-manager options, and half the
sources would then need a second path into the data.

Rejected: an attribute set keyed by application. Merging attribute sets across
modules works, but the natural key is the binding rather than the application,
and a `listOf` keeps contribution to a single append.

### The entry schema is kind-tagged, with a verbatim action

```nix
{
  kind   = "chord";          # chord | prefixed | mapped | word | sequence
  app    = "Hyprland";       # cheatsheet section
  target = "hyprland";       # who binds it; null means documentation only
  desc   = "Toggle floating";
  scopes = [ "desktop" ];    # [] means every scope
  note   = null;             # emitted as a comment by generators that can

  mods   = [ "super" ];      # chord
  key    = "W";              # chord, prefixed
  mode   = [ "n" ];          # mapped
  lhs    = "<Leader>w";      # mapped
  word   = "gsb";            # word
  seq    = "y y";            # sequence

  action  = "togglefloating,";
  variant = "bind";          # hyprland: bind | bindel | bindm
}
```

`action` is never parsed or rewritten. A Hyprland dispatcher, a tmux command
string and a Lua callback have no common structure, and any attempt to unify
them would leak the least expressive target's limits into all of them.

Rejected: a single flat schema with a free-text `key`. That is the status quo in
`myhotkeys.json`, and it is exactly what cannot be validated or rendered.

### Keys are canonical X11 keysyms with per-target renderers

Two existing consumers already speak keysyms: gnome `dconf` writes
`<Shift><Super>Escape`, and `myhotkeys.json` contains `braceleft braceright`.
Hyprland is keysym-shaped and case-insensitive. So keysyms are the canon and
only ghostty needs an alias table (`Return` to `enter`, `space` to `space`).

| canonical `mods=[super shift] key=Return` | rendered |
|-------------------------------------------|----------|
| hyprland   | `$mainMod SHIFT, RETURN`     |
| gnome      | `<Shift><Super>Return`       |
| myhotkeys  | `<SHIFT><SUPER>Return`       |
| ghostty    | `super+shift+enter`          |
| keyb       | `Super + Shift + Return`     |

The allowed keysym set is a curated list in the renderer library, extended when
a binding needs a key not yet in it. Reading `keysymdef.h` from xorgproto would
be more complete but needs a package set, which the registry does not have.
A missing key fails the build with the key named, so the list is cheap to grow
and never silently wrong.

Modifier order is normalised before rendering so that `[ "shift" "super" ]` and
`[ "super" "shift" ]` produce the same output and collide in duplicate
detection.

### The renderers live in `flake.lib.hotkeys`

`modules/nix/helpers.nix` already exposes `flake.lib`. The hotkey helpers go
beside it: selectors (`forTarget`, `forScope`, `byApp`), renderers
(`toHyprland`, `toTmux`, `toGhostty`, `toGnome`, `toFish`, `toKeyb`,
`toMyhotkeys`) and the validator. Consumers call a selector and a renderer;
nobody reimplements a rendering.

### Hyprland: generated file, notes carried as comments

`hypr/binds.conf` stops being a source file and is written from the registry.
The three variants in use (`bind`, `bindel`, `bindm`) become the `variant`
field, and `$mainMod` is emitted rather than expanded, so the generated file
still reads like Hyprland configuration.

The `note` field exists for this target above all. The current file carries
reasoning worth keeping at the point of use, such as why the lock binding
resolves to hyprlock directly instead of `loginctl lock-session`, and why the
suspend binding does not lock first. Moving that reasoning into Nix comments
only would mean it stops shipping to the file read while debugging Hyprland.

Rejected: keeping `binds.conf` authoritative and harvesting annotated lines. It
was the lighter option and it was considered seriously, but it leaves Hyprland
as the one target that cannot be validated, and duplicate detection across
targets then has a hole in it.

### neovim is projected, not re-authored

`packages/mipvim/config/keymaps.nix` is a plain attribute set literal, so
`(import ...).keymaps` evaluates with no package set and no nixvim in scope. The
projection maps each keymap carrying `options.desc` to a `mapped` entry and
drops the rest, because a keymap without a description has nothing to show.

Re-authoring 548 lines into the registry would be a regression: the file already
holds key, mode and description in one place, which is the property this change
is about.

The projection depends on that file staying a plain attribute set. If it ever
becomes a function of `lib` or `pkgs`, the import breaks loudly at eval time
rather than silently producing nothing.

### gnome is generated, and unbinding is a first-class entry

`desktop-shortcuts.nix` sets roughly 25 dconf keys, several deliberately to
`[ ]`. An entry therefore needs to be able to say "this gnome action is bound to
nothing", which is emitted as an empty list and omitted from the cheatsheets.
A bound gnome entry needs a description; an unbinding does not.

### The tmux prefix is written into the key text, not into keyb's `prefix` field

keyb has a per-section `prefix:` field, which looks like a perfect fit until the
`tmxa` and `tmxb` aliases in `shared.shellAliases` are taken into account: they
switch the running prefix between `Ctrl+A` and `Ctrl+B`. A baked prefix would be
wrong half the time and would be wrong silently.

So tmux entries render their key as a prefix-relative string and the section
carries no `prefix:` field.

Rejected: generating the keyb file at popup time from tmux's live prefix. It
turns a static file into a runtime step for a cosmetic gain.

### Context awareness comes from `-k`, not from keyb

Generated into `~/.config/keyb/`: one full file, plus one file per application
that has its own entries. A launcher script bound to a tmux key reads the pane's
command and picks the file.

```
  bind <key> display-popup -E -w .. -h .. 'keyb-popup #{pane_current_command}'
                                                       │
                 tmux expands this against the pane the key was pressed in,
                 before the popup exists, so the popup's own pane cannot
                 shadow the answer
                                                       │
                                                       ▼
                        nvim  ->  ~/.config/keyb/nvim.yml
                        fish  ->  ~/.config/keyb/full.yml
                        other ->  ~/.config/keyb/full.yml
```

Passing the format as an argument on the bind line matters: resolving it inside
the script would ask tmux which pane is current at a moment when the popup is.

Rejected: patching keyb to accept a startup filter. It would work, and the
upstream is active and MIT, but `-k` already gives the same result with nothing
to maintain.

### keyb is packaged as an overlay entry, not as a monorepo package

`buildGoModule` at a pinned tag, in a new `modules/nix/overlays/tools.nix`
registered in `modules/nix/channels.nix`. This is the `clear-sans` case in
`modules/nix/overlays/fonts.nix`: third-party source that nixpkgs does not
carry.

Rejected: `packages/keyb/` with its own flake. The `package-management` spec
reserves that layout for packages whose source lives here, such as mipbar and
mipvim. keyb's source is upstream.

Upstreaming keyb to nixpkgs stays an option afterwards and is not part of this
change.

### `prefix + ?` and keyb are two keys, not one

keyb names command selection as an explicit non-feature. The `display-menu` on
`prefix + ?` fires the highlighted command. Replacing it with keyb would trade
an action for a lookup, so both exist: `?` for the actionable tmux menu, a
second key for the read-only cheatsheet across every application.

The keyb binding is itself a registry entry, so it appears in the `?` menu like
everything else. That works because the menu is a `display-menu` and not a
popup; a `display-popup` invoked from inside a `display-popup -E` exits 0 and
does nothing, which the existing `tmux-bind-registry` spec already records.

## Risks / Trade-offs

- **A registry-wide schema change touches every emitter.** → Keep the emitters
  behind `flake.lib.hotkeys` so a schema change is one library edit plus its
  callers, and never a change inside six application modules.
- **Generated `binds.conf` is one more layer between an edit and a running
  Hyprland.** → The `note` field keeps the reasoning in the generated file, and
  the file stays plain readable Hyprland syntax rather than a machine format.
- **The neovim projection depends on `keymaps.nix` staying a plain attribute
  set.** → It fails at eval time with a clear error if that changes, and the
  projection is one function in one place.
- **Around 200 emitted entries land in one change.** → Migrate target by target,
  each one diffed against the file it replaces before the next starts. The
  registry can hold entries for a target whose emitter is not written yet.
- **Validation that is too strict blocks a binding that works.** → Every rule
  fails with the offending entry named, and a rule applies only to the target
  that needs it. The tmux apostrophe rule does not restrict a Hyprland entry.
- **The curated keysym list will be incomplete.** → An unknown key fails the
  build naming the key, so the fix is one line in the list.
- **`myhotkeys.json` is deleted, and anything in it not carried over is lost.**
  → The file is 328 lines and fully readable; every group is transcribed into
  registry entries as the first migration step, before any generator replaces
  it.

## Migration Plan

1. Land the option module, the renderer library and the validator with an empty
   registry. Nothing generated, nothing changed.
2. Transcribe `myhotkeys.json` into documentation-only entries. The generated
   `keys.json` is compared against the current file; they match except for
   ordering.
3. Per target, in this order, each step diffed before the next: tmux (already a
   registry, so the smallest change), Hyprland (the largest and the one that
   forces the chord renderer to be right), fish, ghostty, gnome.
4. Add the neovim projection.
5. Package keyb, generate the keyb files, add the popup and its key.
6. Delete `myhotkeys.json` and the now-empty hand-written lists.

Rollback is per step: each generator replaces one file, and reverting that
step's commit restores the hand-written file it replaced.

## Open Questions

- Which key opens the keyb popup. It has to avoid the 14 keys already bound in
  the tmux registry, and the answer does not change the specs, the approach or
  the task breakdown.
- Whether the gnome emitter is worth keeping long term, given that
  `modules/USERS/pim/_gnome/` is an underscore-prefixed directory and Hyprland
  is the primary desktop. The emitter is written either way; the question is
  only whether those entries stay in the registry.
