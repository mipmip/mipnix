{
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
}
