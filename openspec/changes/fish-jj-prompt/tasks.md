## 1. jj Detection and Info Functions

- [x] 1.1 Add `is_jj_repo` function that runs `jj root --ignore-working-copy 2>/dev/null` and returns success/failure
- [x] 1.2 Add `pim_jj_prompt` function that uses `jj log -r @ --no-graph --ignore-working-copy -T` with a template to extract change ID, bookmarks, conflict status, and empty/modified status in a single call
- [x] 1.3 Format jj prompt output as colored string: change ID (red), bookmarks (cyan), conflict "⚠" (bold yellow), dirty "✗" (yellow)

## 2. Prompt Integration

- [x] 2.1 Add `pim_vcs_prompt` function that calls `is_jj_repo` first — if true, delegates to `pim_jj_prompt`; otherwise delegates to existing `pim_git_prompt`
- [x] 2.2 Update `fish_prompt` to call `pim_vcs_prompt` instead of `pim_git_prompt`

## 3. Verification

- [x] 3.1 Test in a jj-managed repo: verify change ID and status display correctly
- [x] 3.2 Test in a git-only repo: verify existing git prompt still works
- [x] 3.3 Test outside any repo: verify no VCS info shown
