## Context

The fish prompt in `modules/users/pim/programs/fish/default.nix` uses `fish_git_prompt` and a custom `_pure_prompt_git_dirty` for git status. jj uses git as a backend but operates in detached HEAD, making git prompt output unhelpful. jj 0.35.0 is already installed. The prompt needs to detect jj repos and show jj-native info instead.

## Goals / Non-Goals

**Goals:**
- Detect jj-managed repos and show jj info (change ID, bookmarks, conflicts, dirty state)
- Suppress the confusing git detached HEAD display in jj repos
- Keep the prompt fast (no blocking on slow commands)
- Visual consistency with existing prompt style (colored, concise)

**Non-Goals:**
- Replacing or modifying the existing git prompt behavior for non-jj repos
- Adding right-prompt or multi-line prompt features
- Supporting jj colocated repo detection edge cases beyond `jj root`

## Decisions

### Detection: `jj root` with suppressed output
Use `jj root --ignore-working-copy 2>/dev/null` to detect jj repos. The `--ignore-working-copy` flag skips snapshotting and is fast (~5ms). Falls back to git prompt if jj root fails (exit code != 0).

**Alternative considered**: Checking for `.jj/` directory by walking up — more fragile and reimplements what `jj root` already does.

### Info display: jj template language
Use `jj log -r @ --no-graph -T '<template>' --ignore-working-copy` to extract all info in a single command. The template language gives us change ID (`change_id.shortest()`), bookmarks, conflict status, and empty/modified status in one call.

**Alternative considered**: Multiple `jj` invocations — slower, unnecessary since templates can combine everything.

### Prompt format
Show: `(jj:SHORT_CHANGE_ID BOOKMARKS STATUS)` in the same position as git info. Use colors consistent with the existing scheme:
- Change ID: red (like git branch)
- Bookmarks: cyan
- Conflict indicator: bold yellow "⚠"
- Modified indicator: yellow "✗" (same as git dirty)

### Integration point
Add new functions alongside the existing git functions in `interactiveShellInit`. Modify `fish_prompt` to call a new `pim_vcs_prompt` function that dispatches to jj or git.

## Risks / Trade-offs

- **[Performance]** `jj root` + `jj log` adds ~10-20ms per prompt in jj repos → Acceptable; `--ignore-working-copy` keeps it fast. Cached by shell if typing quickly.
- **[Accuracy]** `--ignore-working-copy` means prompt may be slightly stale → Acceptable trade-off for speed; `jj` auto-snapshots on next real command anyway.
- **[Colocated repos]** A repo could be both git and jj; `jj root` succeeding should take priority → jj check runs first, git is fallback.
