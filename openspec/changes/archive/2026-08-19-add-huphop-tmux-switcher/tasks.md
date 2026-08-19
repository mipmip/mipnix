## 1. Switch wrapper

- [x] 1.1 In `modules/USERS/pim/programs/huphop/default.nix`, add a `let` binding
      `hup-tmux-switch = pkgs.writeShellScriptBin "hup-tmux-switch" '' ... ''`
      implementing Model B (args: short, owner, repo, target), using
      `${pkgs.tmux}/bin/tmux` and sanitising names with `tr ':.' '--'`.
- [x] 1.2 Verify the wrapper logic: create session `<short>-><owner>` + window
      `<repo>` when absent, add the window when the session exists, then
      `switch-client -t "=$sess:$win"`; only tmux server commands, no TTY use.

## 2. Nix-generated config

- [x] 2.1 In the same module, build the config attrset and render it with
      `(pkgs.formats.yaml {}).generate "config.yaml" cfg`, installed via
      `xdg.configFile."huphop/config.yaml".source`.
- [x] 2.2 Reproduce the current working config verbatim: `base_dir: ~`,
      `clone_pattern_tpl`, the `github` provider (`username: mipmip`, ssh,
      `auth.cli: gh`, `env: SKULL2_GITHUB_TOKEN`, `all_owners: true`,
      `include_forks: true`), `default_mode: management`, and both mode blocks
      (`multiplex` footer `[switch_hint, filter]`).
- [x] 2.3 Set the multiplex `switch_command` to
      `'${hup-tmux-switch}/bin/hup-tmux-switch' '{{.Short}}' '{{.OwnerLower}}' '{{.Repo}}' '{{.Target}}'`.

## 3. tmux binding

- [x] 3.1 In `modules/USERS/pim/programs/tmux/default.nix`, add
      `bind G popup -E -w 80% -h 80% 'hup tui --mode multiplex --flatlist'`
      next to `bind S popup -E smg`.

## 4. Verify

- [x] 4.1 `nix build`/flake eval succeeds (module evaluates; note the huphop
      module file must be git-tracked for the flake to see it).
- [x] 4.2 After `home-manager switch`, `~/.config/huphop/config.yaml` is a store
      symlink and `hup config check` passes.
- [x] 4.3 Manual: `prefix + G` opens the flat repo list; selecting an uncloned
      repo clones it, then a repo in a new org creates session `<short>-><owner>`
      + window `<repo>`; a second repo in the same org adds a window; re-selecting
      an open repo just switches. Confirm the popup closes after each switch.
