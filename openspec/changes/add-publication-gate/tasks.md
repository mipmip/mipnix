## 1. Guides as inputs

- [ ] 1.1 Add `humanizer` and `dutch-style-guide` to `flake.nix` as inputs with
      `flake = false`, following the `beans-nvim` precedent. Verify both resolve:
      `nix flake metadata --json | jq '.locks.nodes.humanizer.locked.rev'` and
      the same for the Dutch one return a revision.
- [ ] 1.2 Verify neither adds a nixpkgs node, since a non-flake input has no
      inputs of its own: the count of distinct nixpkgs revisions in `flake.lock`
      is the same before and after. Resolve the root's nixpkgs by following
      `nodes.root.inputs.nixpkgs`, never by indexing the node named `nixpkgs`
      (in this lock that one belongs to agenix).

## 2. Skills and amendments

- [ ] 2.1 Expose both as skills in `modules/programs/dev/vibecoding/claude.nix`:
      humanizer from its root `SKILL.md` (a single file, complete frontmatter),
      the Dutch one from its whole `skills/writing-clearly-and-concisely-dutch/`
      directory, because its SKILL.md refers to the 25 KB reference beside it by
      name. Verify after a rebuild that
      `~/.claude/skills/humanizer/SKILL.md` exists and that the Dutch skill
      directory contains both files.
- [ ] 2.2 Add the amendments as a rules file, stating in writing: that a Dutch
      technical term stays in English when that is the accepted name in its
      field, contrary to the Dutch guide's red flag on English loanwords; that
      humanizer's rule 12 vocabulary list is English-only, as it says itself; and
      that where an imported guide conflicts with `claude-prose-rules`, the local
      rule wins. Verify the file lands in `~/.claude/rules/`.
- [ ] 2.3 Verify the amendments are reachable from the review, not just present:
      the command in task 3.1 names the amendments file explicitly rather than
      hoping the rule file is in memory.

## 3. The gate

- [ ] 3.1 Add the gate as a Claude Code command in `_cc-commands.nix`. It takes
      file paths, and with none it uses the prose files that differ from `HEAD`.
      It runs `prose-lint` over them first and stops there on a blocking hit,
      then reviews what is left against the guides through the amendments, and
      reports findings with their passages without changing anything.
- [ ] 3.2 Verify the hard half fails: run the gate on a file with an em dash
      outside code and confirm it stops, names the file and line, and does not
      proceed to the reading half.
- [ ] 3.3 Verify the soft half reports without failing: run it on a file that is
      typographically clean but carries a forced triad or a staged run-up, and
      confirm findings are reported with their passages, that the gate does not
      fail, and that the file is unchanged afterwards (`git diff` is empty).
- [ ] 3.4 Verify it works on text no tool wrote: create a document with
      `cat > file <<EOF`, which the PostToolUse hook cannot see, and confirm the
      gate checks it in full.
- [ ] 3.5 Verify the no-argument default: with a changed prose file in the tree
      and an unchanged one beside it, the gate checks the first and not the
      second.
- [ ] 3.6 Verify language selection without configuration: a Dutch document draws
      on both guides and an English one on humanizer alone, with no flag passed
      and no marker in the file.

## 4. The working agreement

- [ ] 4.1 Record in the amendments file that prose meant for the user to copy is
      written to a file and the path reported, rather than shown only in a reply,
      so it can pass the gate. Verify by asking for a short piece of prose to
      send to someone and confirming it arrives as a file with its path named.

## 5. Bookkeeping

- [ ] 5.1 Confirm `openspec validate add-publication-gate --strict` passes with
      all four artifacts.
- [ ] 5.2 On archive, record the archived path as `openspec-link` in the
      frontmatter of `.beans/mipnix-jdmy--*.md` and set its status to
      `completed`.
