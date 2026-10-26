## 1. Make the sources shared

- [x] 1.1 Rename `modules/programs/dev/vibecoding/_cc-commands.nix` to `_agent-commands.nix` without touching its contents, and verify the attribute names are unchanged
- [x] 1.2 Rename `modules/programs/dev/vibecoding/_cc-CLAUDEmd.nix` to `_agent-context.nix` without touching its contents
- [x] 1.3 Add `modules/programs/dev/vibecoding/_agent-rules.nix` holding the three rule texts lifted verbatim out of `claude.nix`, taking the filler-word list from `packages/prose-lint/filler-words.json` as `claude.nix` does today, and verify the rendered text is byte-identical to what `claude.nix` produced
- [x] 1.4 Have `claude.nix` import all three instead of defining them inline, and verify the generated `~/.claude/` tree is unchanged from before the rename

## 2. Commands in opencode

- [x] 2.1 Set `programs.opencode.commands` to the shared set in `opencode.nix`, replacing `commands = {}`
- [x] 2.2 Rebuild and verify every `mip:` command exists as `~/.config/opencode/commands/mip:<name>.md`
- [x] 2.3 Verify each opencode command file is byte-identical to the file of the same name under `~/.claude/commands/`
- [ ] 2.4 Start opencode and verify the `mip:` commands appear in the slash-command listing with their descriptions
- [ ] 2.5 Run `/mip:translate hello` in opencode and verify the argument reaches the prompt, so `$ARGUMENTS` is confirmed and not assumed
- [x] 2.6 Verify `argument-hint` in `mip:translate` and `mip:tinychange-explore` does not prevent either from loading

## 3. Context and rules in opencode

- [x] 3.1 Set `programs.opencode.context` to the shared context followed by the three rules, each under its own heading
- [x] 3.2 Rebuild and verify `~/.config/opencode/AGENTS.md` exists as a store symlink containing the context and all three rules
- [ ] 3.3 Start an opencode session and verify it can state a rule from `AGENTS.md` when asked, so the file is confirmed to be in context
- [ ] 3.4 Change one rule's text in Nix, rebuild, and verify both `~/.claude/rules/` and `AGENTS.md` carry the new text

## 4. Skills

- [x] 4.1 Verify `programs.opencode.skills` is unset and no `~/.config/opencode/skills/` directory is created
- [ ] 4.2 Start opencode and verify `humanizer` and `writing-clearly-and-concisely-dutch` are both listed as available skills
- [ ] 4.3 Invoke one of them in opencode and verify its content loads from `~/.claude/skills/`

## 5. What it must not affect

- [x] 5.1 Verify Claude Code still loads all three rules as separate documents from `~/.claude/rules/`
- [ ] 5.2 Verify the `prose-lint` PostToolUse hook still fires on a Claude Code write, by writing a file containing an em dash and confirming the write is reported as failed
- [x] 5.3 Verify `/mip:prosegate` still resolves `~/.claude/rules/prose-review-amendments.md`, which it names by path
- [x] 5.4 Verify every `mip:` command still works in Claude Code after the rename

## 6. Specs and documentation

- [x] 6.1 Update the `mip-init-command` spec for the renamed file and the second deployment location
- [x] 6.2 Update the `claude-prose-rules` spec so the rules requirement names both agents and records that enforcement is not uniform
- [x] 6.3 Note in `_agent-commands.nix` that its frontmatter has to work for both agents, so a future Claude-only key is not added unnoticed
- [x] 6.4 Update the `claude-prose-rules` Purpose, which says the rules are Claude Code's, so it does not contradict its own first requirement
