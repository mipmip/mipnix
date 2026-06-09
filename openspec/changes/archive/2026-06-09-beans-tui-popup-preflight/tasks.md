## 1. Create the beans-tui-popup script

- [x] 1.1 Added `pkgs.writeShellScriptBin "beans-tui-popup"` in the tmux module's `let` (matches the wrofi/smg/open pattern), added to `home.packages`.
- [x] 1.2 Script echoes `CWD: $PWD`, then `find_project()` searches upward for `.beans.yml` (not `beans check`'s exit code).
- [x] 1.3 Happy path: project found → `beans tui`; on non-zero exit, prints exit code + `beans check` + "Press any key to close" + `read -rn1`. Clean exit → script ends → popup closes.
- [x] 1.4 Failure path: no `.beans.yml` → prints no-project message + `beans check` + "Press any key to close" + `read -rn1`.
- [x] 1.5 On PATH via `home.packages` (verified: `home-path/bin/beans-tui-popup`).

## 2. Update the tmux bind

- [x] 2.1 Bind is `bind B popup -E -d '#{pane_current_path}' -w 90% -h 90% 'beans-tui-popup'`. KEPT `-E` (corrected): without `-E`, tmux grabs Escape/C-c to dismiss the popup, hijacking Escape from beans (where it's back-navigation) — the working `bind T` keeps `-E` and Escape passes through. `-E` still works with the preflight pause (the `read` keeps the command alive, so `-E` only closes after the keypress). Added `-d '#{pane_current_path}'` for the cwd fix.

## 3. Build and verify

- [x] 3.1 Built `pim@lego2` (`--impure`, exit 0). Verified: script delivered with correct shell (all Nix `''$` escapes resolved cleanly), bind at `tmux.conf:82`. Ran the script directly: non-project dir → shows CWD + no-project + `beans check`; mipnix root & subdir → `find_project` succeeds and reaches `beans tui` (upward `.beans.yml` search works).
- [x] 3.2 Deploy + reload tmux. In mipnix (valid project): `prefix + B` opens `beans tui`, clean quit closes the popup with no keypress.
- [x] 3.3 In a non-project dir: `prefix + B` shows CWD + `beans check` output and waits for a keypress (no flash-close).
- [x] 3.4 REVEALED the cause: in `technative-project-proposals` the preflight showed `CWD: /home/pim/tcTNxDocs/` (the parent) while the panes were in `.../technative-project-proposals/` — so the popup wasn't using the active pane's cwd. tmux `display-popup` without `-d` uses the SESSION start dir, not the pane cwd. FIXED by adding `-d '#{pane_current_path}'` to the bind (mirrors the existing `bind P`). Rebuilt + verified: `bind B popup -d '#{pane_current_path}' -w 90% -h 90% 'beans-tui-popup'`.

## 4. Verify cwd + Escape fixes (live)

- [x] 4.1 Deploy + reload tmux; from a pane in `technative-project-proposals` (session started elsewhere), `prefix + B` opens `beans tui` for that project (no longer the parent dir).
- [x] 4.2 In the beans popup, press `Escape` inside a filter / detail view → it backs out within beans and does NOT close the popup; the popup closes only when beans itself exits (matches `bind T` behavior).
