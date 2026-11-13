---
name: move-project
description: Rename or move a project directory and take its Claude Code sessions, memory and project settings along. Use when the user wants to rename a repository or its directory, or move a project to another path, and keep resuming its sessions.
---

# Moving a project directory

Claude Code files a project's sessions and memory under
`~/.claude/projects/<encoded path>`, where every character of the absolute
path that is not a letter or digit becomes `-`. Per-project settings sit in
`~/.claude.json` under `.projects["<absolute path>"]`. A directory moved on
its own leaves all of that behind under the old name.

`claude-move-project` moves the three together: the directory, the matching
project folders (including those of subdirectories with their own sessions),
and the keys in `~/.claude.json`, of which it keeps a copy in
`~/.claude.json.before-move`.

## Steps

1. Work out OLD (absolute) and NEW from what the user asked. A bare new name
   means a sibling of OLD.
2. Run `claude-move-project -n OLD NEW` and show the output. The dry run is
   also where it refuses when NEW exists, when a target project folder
   exists, or when a process still runs inside OLD.
3. This session runs inside OLD, so it cannot do the move itself; the script
   will refuse, and a session that keeps running would write to the old
   folder. Give the user the exact commands to run after quitting:

   ```bash
   claude-move-project OLD NEW
   cd NEW && claude --resume
   ```

4. List what still carries the old name, so the user can decide on it. Search
   OLD for it (`git remote -v` or `jj git remote list`, `go.mod`, `package.json`,
   `flake.nix`, `Cargo.toml`, README) and name each hit. For a repository that
   is also renamed on GitHub, mention the remote URL and any flake that takes
   it as an input (for example in `~/mipnix/flake.nix`). Change none of these
   unasked.

## What it does not do

- It does not rename the GitHub repository or change remotes.
- Paths inside old transcripts keep the old name; resuming does not need them.
- Other machines keep their own `~/.claude`; run it there too.
