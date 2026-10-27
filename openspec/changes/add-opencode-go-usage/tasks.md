## 1. The wrapper

- [x] 1.1 Wrap the `src`-fixed opencode package in a `symlinkJoin` with `makeWrapper` (the shell one), keeping `bin/opencode2` and the shell completions intact
  - nixpkgs 2.1.1 ships only `bin/opencode`, no `opencode2`; `share/{bash-completion,fish,zsh,cli.json,config.json,theme.json}` all survive the join.
- [x] 1.2 Add a `--run` body that selects the active credential from `opencode.db` and writes its `.access` field to `$XDG_RUNTIME_DIR/opencode-go-key` with mode 0600, referencing `sqlite3` and `jq` by store path
- [x] 1.3 Make the extraction a read-only `select`, and verify no statement in the wrapper writes to the database
- [x] 1.4 Make every failure path silent: a missing database, no active row, unparseable JSON or an absent `$XDG_RUNTIME_DIR` SHALL leave no file and SHALL NOT stop opencode from starting
- [x] 1.5 Verify `opencode --version` still works under the wrapper, so the extra layer has not broken the binary wrapper underneath

## 2. The plugin entry

- [x] 2.1 Add `@mellena1/opencode-go-usage` to `settings.plugins` as `{ package = ...; options.apiKey = "{file:{env:XDG_RUNTIME_DIR}/opencode-go-key}"; }`
- [x] 2.2 Verify the generated `opencode.json` carries that literal string and that no part of the credential appears in the Nix store
- [x] 2.3 Verify `OPENCODE_API_KEY` is not set anywhere in the module or the wrapper

## 3. It works

- [x] 3.1 Start opencode and verify `$XDG_RUNTIME_DIR/opencode-go-key` exists with mode 0600 and holds a 39-character token
- [x] 3.2 Verify the sidebar shows the three quota windows with percentages and reset countdowns
- [ ] 3.3 Verify `Go usage · refresh` appears in the command palette and that `ctrl+alt+g` triggers a refresh
  - `ctrl+alt+g` refreshes (a local test server counted the extra request). The palette has no entry: the plugin registers its keymap layer with `mode: "base"`, while opencode 2.1.1 lists `visibility: "reachable"` commands and its built-ins use `mode: "global"`. Not fixable from the Nix module. Recorded in `mipnix-nh18`.
- [x] 3.4 Verify the opencode provider still authenticates through the OAuth connection, by confirming models are available and a prompt completes
- [x] 3.5 Verify the peer dependencies resolved: check that `@opentui/core`, `@opentui/solid` and `solid-js` landed under `~/.config/opencode/node_modules` and that no duplicate solid-js warning or render fault appears
  - v2 installs npm plugins under `$XDG_CACHE_HOME/opencode/npm/<pkg>@<spec>/<epoch>/node_modules`; all three peers and `@opencode/plugin` resolved there, no duplicate-solid warning in the TUI log.

## 4. It degrades

- [x] 4.1 Start opencode with the token file removed and `$XDG_RUNTIME_DIR` read-only, and verify opencode starts and the widget hides itself
- [x] 4.2 Point the wrapper at a nonexistent database path, start opencode, and verify it starts with no widget and no error
- [x] 4.3 Write a deliberately invalid token to the file, start opencode, and verify the widget reports a failure rather than hanging on "Loading…"
- [x] 4.4 Verify the token file is gone after a logout, since tmpfs does not survive the session
  - `/run/user/1000` is the systemd per-user runtime tmpfs.

## 5. What it must not affect

- [x] 5.1 Verify the `mip:` commands and `AGENTS.md` still load, so the wrapper did not disturb the config directory
  - Slash menu lists all six `mip:` commands. `AGENTS.md` is still the config directory's context file and rendered unchanged.
- [x] 5.2 Verify the two existing plugins load no worse than before (the open question in `mipnix-gh55`), and record what the wrapper changed, if anything
  - Result: unchanged. In a `~/mipnix` session both store-path plugins rendered live data (BEANS 65 total, OPENSPEC 5 active changes) next to Go usage. The wrapper only adds a `--run` step before `exec` and touches nothing in the config directory, so `mipnix-gh55` stays open on its own merits.
- [x] 5.3 Verify `opencode auth list` still reports the Console credential as stored and active, confirming the wrapper did not touch the row

## 6. Follow-ups

- [x] 6.1 Record a bean for reporting the resolution order upstream: opencode 2 keeps credentials in `opencode.db` rather than `auth.json`, and the OAuth `access` field works against the usage endpoint, so the plugin could resolve it without a wrapper
  - `mipnix-nh18`, with the `value` JSON shape and the suggested resolution order.
- [x] 6.2 Note in the module that the wrapper encodes opencode's auth schema (table, column, JSON field), so a future version moving it again makes the widget go quiet rather than breaking opencode
