## 1. The registry helper

- [x] 1.1 In `modules/USERS/pim/programs/tmux/default.nix`, add a `mkBind`-style
      helper and a `customBinds` list in the module's `let` block, each entry
      carrying `key`, `desc`, `cmd` and `group`.
- [x] 1.2 Derive the `bind` lines from the list, escaping `;` so tmux does not
      read it as a command separator.
- [x] 1.3 Derive the `display-menu` argument list from the same entries: name
      (key plus description), accelerator (the key itself), command (the same
      `cmd` string). Render an empty entry between groups as the separator.
      The command sits in a `{ }` block so `#{pane_current_path}` is stored
      verbatim rather than expanded once at config-parse time.
- [x] 1.4 Assert at eval time that no description starts with `-`, failing the
      build with the offending entry's key. Extended during implementation to
      also reject an apostrophe, which closes the single-quoted menu name early
      and silently drops every entry after it.

## 2. Migrate the bindings

- [x] 2.1 Move the tool bindings into the registry as the first group:
      `S` smug, `G` huphop, `T` tj, `B` beans, `D` beandex, `H` nebula ssh,
      `R` drs, `P` shell at pane path.
- [x] 2.2 Move the tmux bindings into the registry as the second group:
      `s` choose-tree, `b` status bar toggle, `;` last pane zoomed,
      `Tab` last window, `O` open pane path.
      `u` (urlview) is deliberately NOT registered: the key is bound by the
      `tmuxPlugins.urlview` plugin from its own async `run-shell`, with its own
      store paths and its own urlview/extract_url fallback. Registering it would
      mean copying plugin internals into this config and racing the plugin for
      the key. The menu therefore lists 13 entries, and `prefix + u` keeps
      working exactly as before.
- [x] 2.3 Remove the now-duplicated `bind` lines from `extraConfig`, leaving the
      non-registry lines (copy-mode bindings, the Home/End fixes, the
      `bind-key a` escape hack) where they are.
- [x] 2.4 Emit `bind ? display-menu ...` from the registry, replacing tmux's
      default `list-keys` binding on `?`.

## 3. Verification

- [x] 3.1 Built the generated tmux config out of the flake and parsed it:
      `tmux -f <generated> -L verify start-server \; list-keys -T prefix` runs
      with empty stderr, and every registered key is bound to the expected
      command, `;` included. The menu holds all 13 entries plus the separator.
- [x] 3.2 Diffed that `list-keys` output against the pre-change output
      (whitespace normalised, since tmux pads the key column to its widest key):
      of 83 prefix bindings, exactly one differs, `?`, from `list-keys -N` to
      the menu. `u` is byte-identical, confirming the plugin is untouched.
- [x] 3.3 Against a real client on a pty: `prefix + ?` opens the menu, 11 Downs
      then `Enter` fired the `b` entry and flipped the status bar; `Escape`
      closed the menu with the status bar unchanged.
- [x] 3.4 Fired the `P` entry from the menu and confirmed a popup is genuinely
      open afterwards, detected by a second `display-popup` no-opping against
      the client. This is the case a popup-based picker would have lost.
- [x] 3.5 `S` in the menu opens the smug popup and `s` puts the pane in
      `tree-mode`, so same-letter entries fire their own commands.
- [x] 3.6 Compared the `;` entry against `prefix + ;` directly, in both the
      zoomed and unzoomed window states: identical resulting pane and zoom flag.
      (`last-pane -Z` preserves zoom rather than applying it, so an unzoomed
      window stays unzoomed by both paths.) `Tab` was checked the same way and
      also fires from the menu.
- [x] 3.7 Measured the height ceiling: with 13 entries the menu opens and works
      down to a 16-row client, and at 14 rows `display-menu` silently does
      nothing. Headroom is therefore about 3 entries before a 20-row split stops
      showing it. Recorded in design.md.
