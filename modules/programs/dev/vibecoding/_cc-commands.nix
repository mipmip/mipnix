{
  "mip:prosegate" = ''
          ---
          description: gate prose before it leaves my hands, in Dutch or English
          ---
          Check prose before it goes to someone else. Arguments are file paths;
          with none, use the prose files that differ from HEAD
          (`git diff --name-only HEAD -- '*.md' '*.txt' '*.html' '*.rst' '*.adoc'`,
          plus untracked ones).

          Run the two halves in order and keep them apart. The first can fail
          the gate; the second never can.

          ## 1. The hard half

          Run `prose-lint` over every file. If it exits non-zero, STOP. Report
          the hits and offer to fix them, and do not start the reading half.
          These rules are decidable and are the only thing allowed to say no.

          Do not repair a typography hit by substitution. Each one needs its own
          answer: a colon, a comma, parentheses, a sentence break, or a plain
          hyphen when the dash sat in a numeric range. Choose per hit, from the
          meaning.

          ## 2. The reading half

          Read each remaining file against the `humanizer` skill, and for Dutch
          text also against `writing-clearly-and-concisely-dutch`. Read both
          through `~/.claude/rules/prose-review-amendments.md`, which says where
          they do not apply here. Work out the language from the text; do not
          ask and do not expect a marker.

          Report every finding with the passage it sits in and what the guide
          says about it. Report each occurrence separately, even of the same
          pattern, because the repair differs per passage.

          Change nothing on your own. This half reports; the reader decides. If
          the user agrees to a repair, make it as an ordinary edit, and the hard
          half will check it on the way out.

          ## 3. The verdict

          Say plainly whether the gate passed, and list what is left for the
          reader to judge.
  '';

  "mip:1shotpoc" = ''
          ---
          description: creates a new project based on the existing context my way
          ---
          Can you create a set of artifacts I can use to let claude code
          autonomously build the PoC which could serve as an alpha base for
          later development.

          We will use beans as internal ticket system for milestones and epics.
          Run `beans init` to setup and `beans prime` to undestand how it
          works. Claude Code should administer the milestones and epics.
          Milestone title should start with an incremental two digit
          number:starting with `01`

          We will use OpenSpec for creating proposals and keeping track of all
          tasks within an epic. OpenSpec needs to be fully setup before the
          project can take off. start with `openspec init.

          We need thourough testing and e2e testcases to prove our PoC is
          working as it should.

          The PoC need to work with nix and nix flakes from the start. Do
          not use flake-utils but plain nix to setup supported architectures.

          We will use jj for version control. Pim will give you the url of the
          remote repository. You should commit after every archival of a
          openspec change. Commit as Pim Snel, no self promotion.
  '';

  "mip:ship" = ''
    ---
    description: Ship one OpenSpec change end-to-end (apply → gate → archive → commit → push → close bean)
    ---

    Ship the OpenSpec change named in the arguments as a single gated step. One
    change per invocation. Argument: the change name (kebab-case). If omitted, run
    `openspec list` and use the sole active change, or ask which one.

    Do this in order; do not skip the gate:

    1. **Announce & open the bean.** State the change. Find the linked bean (look for
       an "OpenSpec change" note referencing it, or `beans list -S "<change>"`) and
       mark it in-progress: `beans update <id> -s in-progress`. If no bean exists,
       continue without one.

    2. **Implement.** Invoke the openspec-apply-change skill for this change.
       Implement every task with thorough tests and check each off in `tasks.md`
       (`- [ ]` → `- [x]`). Do not stop until all tasks are complete. If genuinely
       blocked, stop and report — do not ship a partial change.

    3. **Update the CHANGELOG.** Add a concise, user-facing bullet to the
       `## [Unreleased]` section of `CHANGELOG.md`, under the right category —
       `### Added` (new capability), `### Changed` (behavior/rename), `### Fixed`
       (bug). Create the category subsection if it's missing. Keep it one or two
       lines describing the change from a user's perspective (not the commit hash).
       `release.sh` promotes this section to a version at release time. (Pure-internal
       refactors with no user-visible effect may skip this — note that you did.)

    4. **Ship (gated).** Run:
       `bash scripts/ship-change.sh <change> "<commit subject>"`
       This stages the tree (including the CHANGELOG edit), runs the gate
       (`nix flake check` — build + tests + coverage ≥70% overall / ≥80% core),
       archives the change, commits as Pim Snel with no self-promotion, and pushes
       `main`. Write a clear one-line commit subject describing the change. If the
       gate fails, fix the code and re-run — never bypass it.

    5. **Close the bean.** Mark the linked bean(s) completed with a
       `## Summary of Changes` section. If the bean is an epic whose parent
       milestone now has all epics completed, mark the milestone completed too.

    6. **Report.** Change archived name, commit id, coverage summary, bean(s) closed.

    Rules: never skip the gate; commit as Pim Snel, no self-promotion; keep changes
  '';

  "mip:flaker" = ''
          ---
          description: creates a flake.nix for the current project
          ---
          check which programming langauge is used for this project and use the
          instructions from https://github.com/mipmip/agent-do-it-my-way for
          make a flake for this project-type. If the language is not listed
          create a flake in the spirit of add-flake-to-nodejs-project.md.
  '';

  "mip:translate" = ''
          ---
          argument-hint: [message]
          description: translates between Dutch and English
          ---
          Translate the following between Dutch and English. Auto-detect
          the source language. Keep the tone and register of the original.

          the following can be
            - a text fragment -> translate in this session
            - a file path -> translate the complete file overwriting the existing text
            - a file path with range -> translate the text withing the range overwriting the existing text

          $ARGUMENTS
  '';

  "mip:tinychange-explore" = ''
          ---
          argument-hint: [intent]
          description: Lean OpenSpec explore for a tiny change (installs the tinychange schema if missing)
          ---
          Start a lightweight exploration for a SMALL change using the `tinychange`
          OpenSpec schema (lean specs -> tasks; no proposal or design). Keep it short —
          this is a tiny change.

          1. Ensure the schema is installed in THIS project. Run:
               openspec schema which tinychange
             If it is NOT found, install it by fetching and following the guide at
             https://raw.githubusercontent.com/speclib/openspec-tinychange-schema/main/AGENT_INSTALL.md
             (it copies openspec/schemas/tinychange/ into this project and validates it).
             Do not proceed until `openspec schema validate tinychange` passes.

          2. Explore briefly, then do a FULL scan of the existing specs
             (`openspec spec list`; read the ones this change could touch) — even a
             small change can shift the specs.

          3. Create the change:
               openspec new change <kebab-name> --schema tinychange
             Write the spec delta under specs/ (ADDED/MODIFIED/REMOVED requirements with
             scenarios) if behavior changes. If it is a pure refactor with NO spec impact,
             set `skip_specs: true` in the change's .openspec.yaml instead of inventing a
             requirement. Also write a short tasks.md (implementation + a verification step).

          4. Note the schema source
             https://github.com/speclib/openspec-tinychange-schema in the change so
             collaborators can install it.

          Stop once the artifacts exist. Do NOT implement — run /mip:tinychange-apply for that.

          $ARGUMENTS
  '';

  "mip:tinychange-apply" = ''
          ---
          argument-hint: [change-name]
          description: Implement + archive a tinychange change (specs -> tasks), then commit
          ---
          Apply a `tinychange` OpenSpec change end-to-end. Argument: the change name; if
          omitted, use the sole active tinychange change or ask which one.

          1. Implement from tasks.md. Reuse the schema-aware apply flow (the
             openspec-apply-change skill) — it reads the tinychange schema and requires
             only tasks. Make the edits, add a real verification step (build/parse/run,
             not "looks right"), and check off each task (- [ ] -> - [x]).

          2. Archive to sync the delta into the main specs:
               openspec archive <change-name>
             Confirm the delta lands in openspec/specs/ (skip_specs changes archive as-is).

          3. Commit per this repo's convention: author Pim Snel, NO self-promoting trailers
             (no Co-authored-by, no Generated-with). One change per commit. Do NOT push — a
             nixos-rebuild verifies nix changes and the rebuild hook handles pushing.

          Report: archived name, commit id, and anything left unverified.

          $ARGUMENTS
  '';

  "mip:init" = ''
    ---
    argument-hint: [project description]
    description: Initialize a new project with OpenSpec + Beans, wired for /mip:ship
    ---
    Bootstrap the CURRENT directory as a new project with OpenSpec and Beans,
    scaffolded so `/mip:ship` works here without any further setup.

    Throughout, `<repo>` means the project repository's directory name (e.g.
    `widgets`). Every generated file uses that name — never the literal `mipnix`.

    ## 1. Interview first — do not scaffold before asking

    Ask all four, then restate the plan and get a go-ahead:

    1. **What is this project about?** A paragraph or two. Feeds the `AGENTS.md`
       overview and the initial beans milestones.
    2. **Register with a central OpenSpec store?** Run `openspec store list`
       first and show what is already registered so the user can pick one.
       On yes, register this project with the chosen store (`openspec store
       register`, or `openspec store setup` for a brand-new one). On no, use a
       repo-local `openspec/` only — create and register nothing.
    3. **Create a `flake.nix`?** For tests, a dev shell, or packaging. Only
       create one if the user agrees; see step 5 for why it matters to shipping.
    4. **`jj` or `git`?** Default `jj`. Decides which `ship-change.sh` variant
       gets written. Ask for the remote URL if there is one.

    ## 2. OpenSpec and Beans

    - `openspec init`
    - `beans init`, then set `prefix: <repo>-` in `.beans.yml`. `beans init`
      accepts no prefix flag, so edit the file. Keep `id_length: 4` so ids read
      `<repo>-rn3b`. Confirm with `beans check`.
    - `beans prime` to learn the workflow, then create the initial milestones
      from answer 1. Milestone titles start with an incrementing two-digit
      number beginning `01`; epics hang under milestones.

    ## 3. AGENTS.md, with CLAUDE.md as a symlink

    Write `AGENTS.md`: a short overview from answer 1, a Commands section, and
    the Beans section below verbatim apart from `<repo>`.

    ~~~markdown
    ## Beans

    When I refer to issues like <repo>-rn3b checkout the task
    in @.beans/<repo>-rn3b-*.md

    In this project we will use these tasks as epics for making openspec proposals.

    WHEN you create a proposal at a link to this task in the proposal.md.
    WHEN a bean is used to create an proposal change the status to "in-progress"
    WHEN a proposal is archived add the link to the archived proposal in the frontmatter of this task like this:

    ```
    openspec-link: openspec/changes/archive/....
    ```

    You are allowed to update these statuses in the task frontmatter:

    - in-progress
    - todo
    - draft
    - completed
    - scrapped

    When making changes you are allowed to update the date/time in `updated_at` in the task frontmatter

    Besides updating status and openspec-link, you are NOT ALLOWED to modify the contents of the task file.
    ~~~

    Then `ln -s AGENTS.md CLAUDE.md`, so every agent reads one source of truth
    and the two cannot drift.

    ## 4. Make /mip:ship applicable

    `/mip:ship` needs three things present. Create all of them.

    **`CHANGELOG.md`** with an `## [Unreleased]` section — step 3 of `/mip:ship`
    appends user-facing bullets there under `### Added` / `### Changed` /
    `### Fixed`.

    **`scripts/ship-change.sh`**, executable. It must refuse to run when tasks
    are unchecked, gate before archiving, and commit/push in the chosen VCS:

    ~~~bash
    #!/usr/bin/env bash
    # ship-change.sh <change-name> [commit-subject]
    #
    # Gated tail for shipping ONE implemented OpenSpec change:
    #   stage -> gate (nix flake check) -> archive -> commit -> push.
    # If the gate fails this aborts before archiving or committing.
    set -euo pipefail

    CHANGE="''${1:?usage: ship-change.sh <change-name> [commit-subject]}"
    SUBJECT="''${2:-Implement ''${CHANGE}}"

    ROOT="$(git rev-parse --show-toplevel)"
    cd "$ROOT"

    TASKS="openspec/changes/''${CHANGE}/tasks.md"
    if [[ ! -d "openspec/changes/''${CHANGE}" ]]; then
      echo "ship: no active change ''${CHANGE} under openspec/changes/" >&2
      exit 1
    fi
    if [[ -f "$TASKS" ]] && grep -qE "^\s*- \[ \]" "$TASKS"; then
      echo "ship: $TASKS still has unchecked tasks — finish the apply step first" >&2
      exit 1
    fi

    echo "==> [1/5] stage working tree (so nix flake sees new files)"
    git add -A

    echo "==> [2/5] gate: nix flake check"
    nix flake check

    echo "==> [3/5] archive OpenSpec change: ''${CHANGE}"
    openspec archive "''${CHANGE}" --yes

    echo "==> [4/5] commit"
    git add -A
    # jj variant:
    jj commit -m "''${SUBJECT}"
    # git variant: git commit -m "''${SUBJECT}"

    echo "==> [5/5] push main"
    # jj variant:
    jj bookmark set main -r @-
    jj git push --bookmark main
    # git variant: git push origin main

    echo "==> shipped ''${CHANGE}"
    ~~~

    Write only the variant the user chose — delete the other and its comment
    marker, do not ship a script with both paths in it.

    ## 5. The gate

    If a `flake.nix` was requested, `nix flake check` must run build, tests, and
    a coverage gate of **>=70% overall and >=80% on core packages** — the gate
    `/mip:ship` documents.

    **Warn the user explicitly:** a project with no tests yet will FAIL that gate
    on its first `/mip:ship`, and the ship will abort before archiving or
    committing anything. That is intended — it means writing tests comes before
    the first ship, and a failed gate never leaves a half-shipped change.

    If the user declined a flake, still write `scripts/ship-change.sh` and
    `CHANGELOG.md`, and say plainly that the gate step is inert until a flake
    exists — offer `/mip:flaker` to create one.

    ## 6. Report

    List what was created, the beans prefix, whether a store was registered, and
    the VCS in use. Mention that the `tinychange` schema (lean specs -> tasks,
    for small changes) can be installed into this project from
    https://github.com/speclib/openspec-tinychange-schema — then
    /mip:tinychange-explore and /mip:tinychange-apply work here too.

    $ARGUMENTS
  '';
}
