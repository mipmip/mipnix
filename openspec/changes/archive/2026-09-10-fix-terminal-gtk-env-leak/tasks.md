# Tasks — fix-terminal-gtk-env-leak

Bean: [mipnix-jdjf](../../../.beans/mipnix-jdjf--sometimes-when-opening-a-new-terminal-i-get-a-lot.md)
— "sometimes when opening a new terminal i get a lot of errors".

Schema source: <https://github.com/speclib/openspec-tinychange-schema>

## Context (verified while exploring)

- Ghostty's nixpkgs wrapper (`makeCWrapper`) exports `GST_PLUGIN_SYSTEM_PATH_1_0`,
  `GI_TYPELIB_PATH`, `GDK_PIXBUF_MODULE_FILE` and a dconf `GIO_EXTRA_MODULES`
  prefix. Every shell in a Ghostty pane inherits them — confirmed: the
  `gstreamer` / `gst-plugins-good` / `gst-plugins-base` store paths in this
  session's `$GST_PLUGIN_SYSTEM_PATH_1_0` are byte-for-byte the ones in the bean's
  error dump.
- The error text is GLib's GIO module scanner. Reproduced verbatim with:
  `env GIO_EXTRA_MODULES="$GST_PLUGIN_SYSTEM_PATH_1_0" gio info /`
  → same `'g_io_module_load': …: undefined symbol` + `Failed to load module: …`
  lines, same store hashes as the bean.
- With the *unmodified* session env (`GIO_EXTRA_MODULES` = gvfs:glib-networking:dconf)
  `gio info /` is silent — so the trigger is a GStreamer plugin dir reaching
  `GIO_EXTRA_MODULES`, which is why it is intermittent ("sometimes"): it depends on
  what the shell/session was launched from.

## 1. Implementation

- [x] 1.1 In `modules/USERS/pim/programs/fish/default.nix`, install the scrub as
      `xdg.configFile."fish/conf.d/00-gtk-env-scrub.fish"`: unexport the three GTK
      wrapper variables and strip `*/gstreamer-1.0` entries from `GIO_EXTRA_MODULES`
      (leave it unset if it was unset, or if nothing survives the filter).
      **Not** `interactiveShellInit` — see 2.3.
- [x] 1.2 In `modules/USERS/pim/programs/zsh/default.nix`, add the same scrub as
      `envExtra` (`.zshenv`), which runs before `.zshrc`. zsh is what non-login
      tooling (e.g. the Claude Code shell) uses, so it needs the same treatment.
- [x] 1.3 Plain shell built-ins only (`set -e` / `unset`, `string split` / `${(s.:.)}`)
      — no extra packages, no new module.

## 2. Verification

- [x] 2.1 `nix eval --impure .#homeConfigurations."pim@doornappel".config.programs.{fish,zsh}.…`
      evaluates and the generated files contain the scrub with the zsh `''${(s.:.)}`
      escaping intact.
- [x] 2.2 Behavioural matrix, running the *generated* snippets in real `fish` and `zsh`:
      | case                                    | result                                    |
      |-----------------------------------------|-------------------------------------------|
      | gst dir in the middle of GIO_EXTRA_MODULES | gst entry dropped, others kept in order |
      | clean GIO_EXTRA_MODULES                 | unchanged                                 |
      | GIO_EXTRA_MODULES unset                 | stays unset                               |
      | GIO_EXTRA_MODULES = only gst dirs       | unset                                     |
      All four pass in both shells; the three wrapper vars are empty in every case.
- [x] 2.3 Ordering — the reason 1.1 uses `conf.d` and not `interactiveShellInit`:
      with a polluted `GIO_EXTRA_MODULES`, `fish -i -c 'echo MARKER'` prints the
      `Failed to load module` lines *before* `MARKER`. Traced to
      `/run/current-system/sw/share/fish/vendor_conf.d/flatpak.fish`, which runs
      `flatpak --installations` (a GLib program) on every fish start. fish sources
      `conf.d` sorted by filename, so the `00-` prefix wins. zsh has no equivalent
      early hook (`zsh -ic` printed nothing), but `.zshenv` is used for symmetry.
- [x] 2.4 Verified in an isolated fish config dir that `00-gtk-env-scrub.fish` is
      sourced before the flatpak vendor hook and silences the errors.
- [x] 2.5 End-to-end with the real generated files (isolated `XDG_CONFIG_HOME` /
      `ZDOTDIR`): a polluted environment that produced **76** `Failed to load module`
      lines produces **0** with the scrub in place, in both shells, including a real
      `gio info /` call from zsh.
- [x] 2.6 Regression — wrapped GTK apps still start from a cleaned environment:
      `walker --version` → `2.16.2`, `ghostty +version` → `Ghostty 1.3.1`, both rc=0.
- [ ] 2.7 **Left for the rebuild**: after `nixos-rebuild switch`, open a new Ghostty
      window and confirm the three variables are empty in fish, in zsh, and in a
      tmux pane opened from that window.
