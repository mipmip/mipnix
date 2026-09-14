## 1. Rule files

- [x] 1.1 Add `programs.claude-code.rules` to
      `modules/programs/dev/vibecoding/claude.nix` with two entries:
      `prose-typography` (no em dash, en dash, ` -- ` used as a dash, or curly
      quotation marks; name the relation or split the sentence instead) and
      `prose-filler-words` (the list, with the rule that a listed word stays
      when it carries meaning and goes when it is a tic). Verify both land:
      after a rebuild, `ls ~/.claude/rules/` shows `prose-typography.md` and
      `prose-filler-words.md`.
- [x] 1.2 Verify the existing `context` string is untouched and still carries
      the commit-attribution rule, the markdown table rule and the RTK section:
      `grep -c 'Co-authored-by' ~/.claude/CLAUDE.md` returns 1.

## 2. The linter

- [x] 2.1 Build the linter as a derivation in `claude.nix` with its interpreter
      resolved at build time (a `writers.writePython3Bin` or equivalent), so no
      language runtime is needed on PATH. Verify it is executable and runnable
      straight from the store: `nix eval` the path, then run it with `--help` or
      an empty event on stdin from a shell with a stripped PATH.
- [x] 2.2 Implement the region carve-out first, before any rule: fenced code
      blocks, inline code spans, URLs and filesystem paths are excluded from all
      checking. Verify with a fixture containing `nixos-rebuild --flake .#host`,
      a fenced block holding ` -- `, and an https URL with a dash: zero hits.
- [x] 2.3 Implement the blocking rules (em dash, en dash, ` -- ` as a dash,
      curly quotes). On a hit, write each offending line and its text to stderr
      and exit 2. Verify with a fixture: exit status is 2 and stderr names the
      line number.
- [x] 2.4 Implement the filler report from the list in the rule file, as a
      non-blocking report: each hit printed with the sentence it sits in, exit
      status still 0 when no blocking rule fired. Verify with a fixture holding
      both "dat is eigenlijk niet waar" and "dat is eigenlijk best goed": both
      are reported, exit status is 0.
- [x] 2.5 Verify the file-type scope: the linter reads the written file's path
      from the hook event and does nothing at all for a path that is not `.md`,
      `.txt`, `.html`, `.rst` or `.adoc`. Verify by feeding it an event naming a
      `.nix` file containing an em dash: exit 0, no output.
- [x] 2.6 Verify it never breaks a session on bad input: feed it malformed JSON,
      an empty stdin, and an event naming a file that does not exist. Each
      returns 0 and prints nothing.

## 3. Wiring

- [x] 3.1 Register the linter in `settings.hooks.PostToolUse` with matcher
      `Write|Edit`, referencing the store path of the derivation from task 2.1
      rather than a bare interpreter name. Verify with
      `jq '.hooks.PostToolUse' ~/.claude/settings.json` after a rebuild: the
      command is an absolute `/nix/store/...` path.
- [x] 3.2 Verify end to end by driving the registered command with the event
      shape Claude Code sends, rather than by switching this machine (switching
      is the operator's step, per the ship-change.sh header). A markdown file
      holding two em dashes returns exit 2 and names `line 1, em dash` twice;
      the same file rewritten with commas returns exit 0 and prints nothing.
      The command exercised is the exact `/nix/store/...-prose-lint/bin/prose-lint`
      recorded in the generated `settings.json`.
- [x] 3.3 Verify the filler path the same way: a file holding both "Dat is
      eigenlijk best goed" and "Dat is eigenlijk niet waar" reports both with
      their own sentence and returns exit 0, so neither blocks the write.

## 4. Bookkeeping

- [x] 4.1 Confirm `openspec validate add-prose-rules --strict` passes with all
      four artifacts present.
- [ ] 4.2 On archive, record the archived path as `openspec-link` in the
      frontmatter of `.beans/mipnix-pdlz--*.md` and set its status to
      `completed`. Leave `mipnix-jdmy` on `todo`; its `blocked_by` clears when
      this lands.
