## 1. Package the two tools

- [x] 1.1 Add `nping.url = "github:mipmip/nping"` and `updo.url =
      "github:mipmip/updo"` to `flake.nix` inputs, next to `huphop` and
      `beandex`, each with `inputs.nixpkgs.follows = "nixpkgs"` unless upstream
      pins a toolchain it needs; verify with `nix flake metadata` that both
      resolve and that `nix build .#nixosConfigurations.<thishost>.config.system.build.toplevel`
      still evaluates
- [x] 1.2 Confirm the attribute path of each package
      (`inputs.nping.packages.${system}.<name>`) by `nix eval`, so the launcher
      references the right one rather than a guess

## 2. One host list

- [x] 2.1 Add `nebulaHostNames = lib.attrNames self.nebulaNodes;` to
      `flake.lib` in `modules/nix/helpers.nix`, beside `nebulaHosts`; verify
      `nix eval .#lib.nebulaHostNames` lists every active node and no others
- [x] 2.2 Verify `nix eval .#lib.nebulaHosts` is unchanged, so the `prefix + H`
      picker is untouched

## 3. The launcher

- [x] 3.1 Add `nebula-monitor` as a `writeShellScriptBin` in the tmux module's
      `let` block, reading a `monitor.sh` file beside `float.sh`, and add it to
      `home.packages`; verify `nebula-monitor` is on PATH after a rebuild
- [x] 3.2 Implement `ensure`: create the `_nbmon` session detached with `nping`
      in pane 1 if it does not exist, split `-h` for `updo`, set
      `remain-on-exit on` and `status off` on the session; verify by running
      `nebula-monitor open` and checking `tmux list-panes -t =_nbmon` shows two
      panes
- [x] 3.3 Implement the respawn pass: for each pane whose `#{pane_dead}` is
      set, `respawn-pane` with that index's command, leaving live panes alone;
      verify by killing `updo` inside the popup, reopening, and confirming the
      right pane runs `updo` again while `nping`'s process id is unchanged
- [x] 3.4 Implement `open`: read `#{client_tty}` first, then `display-popup -c`
      that tty at `-w 98% -h 85% -b rounded -E "TMUX= tmux attach -t =_nbmon"`;
      verify the popup opens over the current pane and both tables render

## 4. The binding

- [x] 4.1 Add the `prefix + M` entry to `binds.nix` in the `tools` group as a
      conditional: `detach-client` when `#{session_name}` is `_nbmon`, else
      `run-shell -b 'nebula-monitor open'`; verify `tmux list-keys | grep ' M '`
      reports the conditional back
- [x] 4.2 Verify `prefix + ?` lists the `M` row in the tools group and that
      firing it from the menu opens the popup
- [x] 4.3 Verify the generated cheatsheet contains the `M` binding and that no
      other binding changed, by diffing the cheatsheet against the previous
      build

## 5. The smug session

- [x] 5.1 Pass `inputs` into `_advanced_smugs.nix` from
      `smug_n_skull/default.nix`; verify the home configuration still evaluates
- [x] 5.2 Replace the two `nix run` commands in the `CoreVitals` window with
      store-path invocations over `self.lib.nebulaHostNames`; verify by opening
      the smug `monitoring` session and checking both panes start without a
      download step
- [x] 5.3 Verify no literal nebula host name is left in
      `_advanced_smugs.nix` with `grep -nE 'harry|hurry|lavendel|dapperehaan|durer'`

## 7. The close key

- [x] 7.1 Emit `bind -n` for a registered `chord` on the tmux target in
      `lib/hotkeys.nix`, leaving `prefixed` entries emitting `bind` as before;
      verify by evaluating `toTmuxBinds` that the chord gains `-n` and that no
      existing line changed
- [x] 7.2 Reject a tmux chord carrying a modifier, since no tmux spelling for
      one exists; verify the build fails with a message naming the entry
- [x] 7.3 Add the `Escape` chord to `binds.nix` in the `tmux` group with
      `menu = false`, guarded on `#{==:#{session_name},_nbmon}` and falling
      through to `send-keys Escape`; verify the cheatsheet row reads `Esc` with
      no prefix label
- [x] 7.4 Verify Escape closes the popup from a real client and both tool pids
      survive, and that Escape outside the popup detaches nothing

## 6. Verification against the spec

- [x] 6.1 Verify persistence: open the popup, wait through several `nping`
      intervals, close with `prefix + M`, reopen, and confirm the table shows
      the samples taken while the popup was closed and `updo`'s uptime covers
      the whole period
- [x] 6.2 Verify the toggle closes rather than nests: press `prefix + M` inside
      the popup and confirm the popup closes and the underlying window is
      unchanged
- [x] 6.3 Verify no duplicate session after several open and close cycles with
      `tmux list-sessions | grep _nbmon` and `tmux list-panes -t =_nbmon`
- [x] 6.4 Verify the registry is the source: add a throwaway node to
      `flake.nebulaNodes`, rebuild, confirm it appears in both the popup and
      the smug session, then remove it
- [x] 6.5 Verify the offline path: disconnect from the internet, open the
      popup, and confirm both tools start
- [x] 6.6 Run `openspec validate --strict add-nebula-monitor-popup` and confirm
      it passes
