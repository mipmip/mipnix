## 0. Context

New Claude Code slash command `/mip:init` that bootstraps a fresh project with
OpenSpec + Beans, wired so `/mip:ship` works there.

**Where it lives.** The `mip:` commands are not loose files — they are attributes of
`modules/programs/dev/vibecoding/_cc-commands.nix`, imported by
`modules/programs/dev/vibecoding/claude.nix:8` (`commands = import ./_cc-commands.nix`)
and deployed by home-manager as store symlinks into `~/.claude/commands/`. So this
change adds one attribute to that file; nothing is written to `~/.claude` by hand.

**What `/mip:ship` needs** (from `~/.claude/commands/mip:ship.md`): `scripts/ship-change.sh`,
a `CHANGELOG.md` with `## [Unreleased]`, a `nix flake check` gate with coverage
≥70% overall / ≥80% core, and the `beans` CLI. mipnix itself has none of the first
three — `/mip:ship` was written for the projects `/mip:init` will create.

**Reference implementation** to copy the ship script from:
`/home/pim/gh.mipmip/huphop/scripts/ship-change.sh` (jj variant).

Decisions taken during exploration:

| Question | Decision |
|-------------------|--------------------------------------------------------|
| VCS | Ask at runtime, default `jj`; write the matching script |
| Ship gate | Full gate including coverage; warn that tests come first |
| Agent file | `AGENTS.md` is the source of truth, `CLAUDE.md` a symlink |

Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 Add a `"mip:init"` attribute to
      `modules/programs/dev/vibecoding/_cc-commands.nix`, following the existing
      entries' shape: a `''…''` string opening with `---` frontmatter carrying a
      `description`. Mind Nix string escaping — `''${...}` for any literal shell
      interpolation in the embedded scaffolding.
- [x] 1.2 In the command body, specify the interview: what the project is about;
      whether to register with a central OpenSpec store (listing existing ones via
      `openspec store list`, then `openspec store register`); whether to create a
      `flake.nix`; and `jj` vs `git` (default `jj`).
- [x] 1.3 Specify the initialization steps: `openspec init`, `beans init`, then set
      `prefix: <repo-name>-` in `.beans.yml` (`beans init` has no prefix flag) and
      confirm with `beans check`. Mention `beans prime` for the agent to learn beans.
- [x] 1.4 Specify writing `AGENTS.md` with the `## Beans` epic convention, with the
      issue prefix templated to the repo name — not the literal `mipnix` — and
      `CLAUDE.md` created as a symlink to `AGENTS.md`.
- [x] 1.5 Specify scaffolding `scripts/ship-change.sh` (executable, unchecked-task
      guard, gate before archive, commit/push in the chosen VCS) and a `CHANGELOG.md`
      with an `## [Unreleased]` section.
- [x] 1.6 Specify the coverage gate in `flake.nix` (≥70% overall, ≥80% core) and an
      explicit warning that the first `/mip:ship` will fail the gate until the
      project has tests. If the user declined a flake, say the gate step is inert
      until one exists and point at `/mip:flaker`.
- [x] 1.7 Have the command close by reporting what was created and noting that the
      `tinychange` schema can be installed from
      https://github.com/speclib/openspec-tinychange-schema.

## 2. Verification

> 2.3 and 2.4 need a home-manager switch (`~/.claude/commands/*` are Nix-store
> symlinks) plus an interactive `/mip:init` run, so they are outstanding. The
> build-level and script-level equivalents are recorded in 2.1, 2.2 and 2.5.

- [x] 2.1 `nix eval` on the attribute returns the command text — the Nix string
      parses. Escaping verified on the rendered output: the embedded script carries
      real `${1:?…}`, `${2:-Implement ${CHANGE}}`, `${CHANGE}`, `${SUBJECT}` and
      `$ARGUMENTS`, with no `''$` escape leftovers. Note `'''` had to be avoided
      entirely — in Nix it means a literal `''`, so the two `echo` lines that
      originally single-quoted `${CHANGE}` were rewritten without the quotes.
- [x] 2.2 `home.file` for `pim@doornappel` now lists
      `/home/pim/.claude/commands/mip:init.md` alongside the other six `mip:`
      commands, and building that file derivation produces a 160-line file whose
      frontmatter carries the `description`. The only occurrence of the string
      `mipnix` is the instruction telling the agent never to emit it (line 9) —
      the template itself uses `<repo>` throughout.
- [ ] 2.3 After a home-manager switch, `/mip:init` appears in Claude Code's
      slash-command list with its description.
- [ ] 2.4 End-to-end in a throwaway directory: run `/mip:init`, answer the interview,
      then confirm `openspec/`, `.beans/`, `.beans.yml` (prefix = dir name),
      `AGENTS.md` (`## Beans` present, prefix templated, no literal `mipnix`),
      `CLAUDE.md` → `AGENTS.md` symlink, `scripts/ship-change.sh` (executable),
      and `CHANGELOG.md` with `## [Unreleased]`.
- [x] 2.5 Extracted the embedded `ship-change.sh` from the rendered command and
      exercised it in a throwaway git repo, ahead of `/mip:init` ever running:
      `bash -n` passes; no args → exit 1 (usage); unknown change → exit 1;
      change with an unchecked task → exit 1 **before** the gate; all tasks
      checked → proceeds to `nix flake check`. Nothing was archived or committed
      on any failure path. Also confirmed the guard regex `^\s*- \[ \]` matches
      `- [ ]` and not `- [x]`.
