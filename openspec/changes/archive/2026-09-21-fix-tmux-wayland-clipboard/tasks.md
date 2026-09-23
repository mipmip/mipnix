## 1. Implementation

- [x] 1.1 Added `set -ga update-environment WAYLAND_DISPLAY` to `extraConfig` in
      `modules/USERS/pim/programs/tmux/default.nix`, with a comment naming the
      reason (the server's environment has no `WAYLAND_DISPLAY`, this session's
      socket is `wayland-1`, and `atotto/clipboard` skips wl-copy without it).
- [x] 1.2 Changed the copy-mode yank binding from `xclip -in -selection
      clipboard` to `${pkgs.wl-clipboard}/bin/wl-copy`, by store path, as
      `nautilus-copy-path` does.
- [x] 1.3 Left the `v` and `V` copy-mode bindings alone and out of the bind
      registry.

## 2. Verification

- [x] 2.1 Built the generated tmux config: line 78 is
      `set -ga update-environment WAYLAND_DISPLAY`, and the yank binding names
      `/nix/store/1gr1q49h2dh0zn96vgaxsxrk26mvac5k-wl-clipboard-2.3.0/bin/wl-copy`,
      which exists and is executable. The only remaining `xclip` mentions are in
      comments.
- [x] 2.2 Started a tmux server on the generated config with no
      `WAYLAND_DISPLAY` in its environment, exactly like the real one:
      `update-environment` lists `WAYLAND_DISPLAY` alongside all nine tmux
      defaults (the `-a` append kept them), and `show-environment` reports
      `-WAYLAND_DISPLAY`, tmux's notation for "unset this", which is the
      no-Wayland-session case. After attaching a client that carries
      `WAYLAND_DISPLAY=wayland-1`, the session environment reports
      `WAYLAND_DISPLAY=wayland-1`.
- [x] 2.3 In a NEW pane of that server: `WAYLAND_DISPLAY=wayland-1`, and
      `wl-paste -l` reached the real compositor and listed the offered MIME types
      with exit 0. The same command fails with "Failed to connect to a Wayland
      server" in a pane of the current server, which is the bug.
      Used `wl-paste -l` rather than `wl-copy` deliberately: it proves the
      connection without overwriting the live clipboard.
- [x] 2.4 Verified the popup path, which is how beans is launched: a
      `display-popup -E` on that server sees `WAYLAND_DISPLAY=wayland-1` and
      reaches the compositor.
      NOT RUN: clicking Yank in the beans TUI itself. That needs the real session
      after a rebuild, and it writes to the live clipboard. The mechanism behind
      the reported error is verified; the click is left as the user's check.
- [ ] 2.5 Select text in copy mode, press `y`, and paste into a Wayland
      application.
      NOT RUN: a yank necessarily overwrites the live clipboard, so this was left
      to the user rather than clobbering it from a test harness. The binding's
      target is verified to exist (2.1) and wl-clipboard is verified to reach the
      compositor from a pane (2.3).

## 3. After the rebuild

- [ ] 3.1 `update-environment` refreshes the session at attach time, so the
      RUNNING tmux server keeps the old environment until it is re-attached, and
      panes that already exist keep it regardless. Detach and re-attach (or
      `tmux kill-server`), then confirm with
      `tmux show-environment | grep WAYLAND_DISPLAY`.
