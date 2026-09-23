Schema source: https://github.com/speclib/openspec-tinychange-schema

Today `prose-lint` exists only as the PostToolUse hook command. `which
prose-lint` finds nothing, and its only interface is a JSON hook event on
standard input, so checking a file you are not editing means hand-writing that
JSON. This makes it a tool you can also run yourself.

## 1. Implementation

- [x] 1.1 In `packages/prose-lint/prose_lint.py`, add a command-line mode: when
      the process is given path arguments, check each of them and report; when
      it is given none, keep reading a hook event from standard input exactly as
      now. Exit non-zero from the command-line mode when any file hit a blocking
      rule, and keep the hook's exit 2 for the stdin path, since that code is
      what Claude Code reads as "fix this".
- [x] 1.2 In command-line mode, skip the prose-extension filter: a named file is
      checked whatever it is called. The filter exists so the hook does not fire
      on source files on its own, which is not a reason to refuse a direct
      request.
- [x] 1.3 Add tests to `packages/prose-lint/test_prose_lint.py` covering both
      modes: one file with a violation exits non-zero, several files each get
      their own report, a `.nix` file named explicitly is checked while the same
      file arriving through a hook event is still skipped, and no arguments with
      an empty stdin still exits 0.
- [x] 1.4 Put the package on PATH by adding it to `home.packages` in
      `modules/programs/dev/vibecoding/claude.nix`, reusing the `proseLint`
      binding the hook command already uses so there is one derivation, not two.

## 2. Verification

- [x] 2.1 `nix build .#checks.x86_64-linux.prose-lint` passes with the new tests.
- [x] 2.2 Build the home configuration and confirm the command is on PATH:
      `<activationPackage>/home-path/bin/prose-lint` exists.
- [x] 2.3 Run it against a real document with known hits, for example
      `docs/spike-tmux-reading-mode.md`, and confirm the output matches what the
      hook reports for the same file and that the exit status is non-zero.
- [x] 2.4 Confirm the hook is untouched: the registered command in the generated
      `settings.json` still points at the same derivation, and writing a prose
      file with an em dash still fails with exit 2.
