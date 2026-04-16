## Why

Fish shell's custom prompt shows git branch/dirty status via `fish_git_prompt` and `_pure_prompt_git_dirty`. When working in jj-managed repos, jj uses git as a backend but operates in a detached HEAD state, causing the prompt to show unhelpful "(HEAD detached at ...)" instead of meaningful jj context like the current change ID, branch bookmarks, or working-copy status. This makes the prompt confusing and useless in jj repos.

## What Changes

- Add a jj detection function that checks if the current directory is inside a jj-managed repo
- Add a jj prompt function that displays relevant jj info (change ID, bookmarks, working-copy status)
- Modify the main `fish_prompt` to use the jj prompt when in a jj repo, falling back to the existing git prompt otherwise
- The jj prompt should visually integrate with the existing prompt style (colored, concise)

## Capabilities

### New Capabilities
- `jj-prompt`: Fish shell prompt integration for jj (jujutsu) repos — detection, change ID display, bookmark display, and dirty/conflict status

### Modified Capabilities

## Impact

- **Code**: `modules/users/pim/programs/fish/default.nix` — the `interactiveShellInit` section where prompt functions are defined
- **Dependencies**: Requires `jj` to be installed (already available via `git-utils.nix`)
- **Systems**: Fish shell prompt in all terminals
