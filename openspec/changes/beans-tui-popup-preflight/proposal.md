## Why

The `prefix + B` tmux popup runs `beans tui` directly with `popup -E`, so if `beans tui`
can't start (or exits non-zero) the popup closes instantly — a silent flash with no
indication of why. This already bit a real case: in a *valid* beans project
(`technative-project-proposals`, 23 beans, `beans check` passing) the popup still
flash-closed, and the `-E` auto-close hid the actual error.

Making the popup self-diagnosing — preflight + verbose failure that holds open — both
improves day-to-day UX and surfaces the underlying cause of that flash-close (which is
still unknown). It turns an invisible failure into a readable one.

Related task: [mipnix-tn0f](.beans/mipnix-tn0f--add-tmux-shortcut-which-shows-large-popup-with-bea.md)

## What Changes

- Replace the inline `beans tui` in the `prefix + B` bind with a small shell script
  (`writeShellScriptBin "beans-tui-popup"`, matching the existing wrofi/smg/open pattern).
- The script: echoes the CWD in use, runs `beans check`, and:
  - **happy path** — launches `beans tui`; when the user quits normally the popup closes.
  - **failure path** — if the project can't be resolved / `beans tui` exits non-zero, it
    shows the CWD used and the `beans check` output, then waits for a keypress before
    closing ("Press any key to close").
- Drop `-E` from the bind so the script controls the popup lifecycle (close on clean quit,
  hold open on failure).

Note: `beans check` exits 0 even in a non-project dir (it prints an error but returns 0),
so the preflight gates on the project marker (`.beans.yml` searched upward), not on
`beans check`'s exit code — while still showing `beans check` output for diagnostics.

## Capabilities

### Modified Capabilities

- `tmux-beans-popup`: The `prefix + B` popup now runs via a `beans-tui-popup` script that
  preflights and, on failure, shows the CWD + `beans check` output and waits for a keypress
  instead of silently flash-closing. Happy-path behavior (open `beans tui`, close on quit,
  run in the pane's directory) is preserved.

## Impact

- `modules/USERS/pim/programs/tmux/default.nix`: change `bind B` to drop `-E` and call
  `beans-tui-popup` instead of `beans tui`.
- New `beans-tui-popup` script (a `writeShellScriptBin` package, added where pim's small
  CLI helpers live), on PATH so the bind can call it.
- `beans` remains the only runtime dep (already on PATH).
- Diagnostic benefit: the next time the popup fails (e.g. in technative-project-proposals),
  it will display the real reason/exit code instead of vanishing.
