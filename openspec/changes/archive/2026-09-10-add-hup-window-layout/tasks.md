## 1. Wrapper changes

- [x] 1.1 `new-session` branch captures the created window's first pane id via
      `-P -F '#{pane_id}'` into `$left`. Verified in the built script
      (`/nix/store/…-hup-tmux-switch/bin/hup-tmux-switch`).
- [x] 1.2 `new-window` branch assigns the same `$left` variable, which is
      initialised empty before the `if`, so the already-open path leaves it unset.
- [x] 1.3 Two splits added under `[ -n "$left" ]`:
      `split-window -d -h -l 50% -t "$left" -c "$target" -P -F '#{pane_id}'` then
      `split-window -d -v -l 50% -t "$right" -c "$target"`.
- [x] 1.4 `select-pane -t "$left"` runs inside the same guard, before
      `switch-client`.
- [x] 1.5 Comment block added covering the pane-id-not-index choice, the
      creation-only guard, and why explicit splits beat `main-vertical` (the global
      `main-pane-width 80` that smug's layouts depend on). Includes the layout
      diagram.

## 2. Build verification

- [x] 2.1 Built the real artifact rather than reasoning about the Nix source:
      `nix build --impure .#homeConfigurations."pim@doornappel".config.xdg.configFile."huphop/config.yaml".source`
      builds `hup-tmux-switch` as a dependency; read the generated script end to
      end and it is as intended.
- [x] 2.2 Ran the **built wrapper** against an isolated tmux server
      (`TMUX_TMPDIR=/tmp/hupship`, `pane-base-index 1`, `main-pane-width 80`).
      Branch A (session absent) on an 80x24 window:

      | pane | x  | y  | w  | h  | active | start path                     |
      |------|----|----|----|----|--------|--------------------------------|
      | %0   | 0  | 0  | 39 | 24 | **1**  | /home/pim/gh.mipmip/startaste  |
      | %1   | 40 | 0  | 40 | 11 | 0      | /home/pim/gh.mipmip/startaste  |
      | %2   | 40 | 12 | 40 | 12 | 0      | /home/pim/gh.mipmip/startaste  |

- [x] 2.3 Branch B (session exists, window absent) produced identical geometry —
      `%3` 39 cols active, `%4`/`%5` 40 cols at h=11/12, all three rooted at the
      passed target.
- [x] 2.4 Resize 80x24 → 160x40 held the proportions: 79 / 80 columns, and 19 / 20
      rows in the right column.
- [x] 2.5 Branch C (already open) is inert: killed `%2` by hand and focused `%1`,
      then re-ran the wrapper for that repo. Pane list stayed `%0 %1` — nothing
      re-split — and `%1` remained the active pane, so nothing was re-focused
      either. Scratch server killed afterwards.

## 3. Live verification — needs an attached client, left for Pim

These four need a real `nixos-rebuild`/home-manager switch plus hands on the
keyboard driving the huphop TUI, so they could not be executed here. The
mechanics behind 3.1–3.3 are covered by 2.2, 2.3 and 2.5 against the built
wrapper; what remains untested is the path *through* the TUI.

- [ ] 3.1 After switching, open `prefix + G`, select a repo that is not currently
      open, and verify the window appears with the three-pane layout, cursor in the
      left pane, and all three panes' `pwd` at the checkout path.
- [ ] 3.2 Close one of the right-hand panes, re-select the same repo via
      `prefix + G`, and verify the window is switched to unchanged — no re-split and
      no focus change.
- [ ] 3.3 Select a repo whose org session does not exist yet and verify the first
      window of the newly created session gets the same layout.
- [ ] 3.4 Confirm no regression in the untouched behaviour: session naming
      (collection vs `<short>-><owner>`), window naming, and `hup config check`
      still reporting the configuration valid.
