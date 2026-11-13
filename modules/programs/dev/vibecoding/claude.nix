{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config =
    { pkgs, lib, unstable, ... }:
    let
      # The PostToolUse checker. Referenced by store path, never by a bare
      # interpreter name: programs.claude-code.hooks writes its files without an
      # executable bit, and naming `python3` in the command would make the hook
      # die silently in any shell that lacks it.
      proseLint = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".prose-lint;

      # Moves a project directory together with its sessions, memory and
      # settings. The move-project skill drives it.
      claudeMoveProject = import ./_claude-move-project.nix { inherit pkgs; };
    in
    {

    # The checker is also a tool you can run yourself: `prose-lint FILE...`.
    # Same derivation the hook uses, so there is one of it, not two.
    home.packages = [ proseLint claudeMoveProject ];

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      # Shared with opencode. Both agents derive the slash name from the
      # filename, so `mip:ship.md` answers to /mip:ship in each, and both
      # implement $ARGUMENTS, $1, shell injection and @file. Frontmatter added
      # here has to work for both: a key only one of them knows is ignored by
      # the other, silently.
      commands = import ./_agent-commands.nix;

      # Declared here only. opencode scans ~/.claude/skills/<name>/SKILL.md
      # itself, so these serve both agents and `programs.opencode.skills` stays
      # unset rather than writing a second copy.
      # humanizer keeps its SKILL.md at the repository root, so one file is
      # enough. The Dutch guide's SKILL.md refers to the 25 KB reference beside
      # it by name, so that one needs the whole directory.
      skills = {
        humanizer = "${inputs.humanizer}/SKILL.md";
        writing-clearly-and-concisely-dutch =
          "${inputs.dutch-style-guide}/skills/writing-clearly-and-concisely-dutch";
        move-project = ./_skill-move-project.md;
      };

      # Separate documents, one per concern: Claude Code loads every markdown
      # file in ~/.claude/rules/ as memory, so a rule can be added or removed
      # on its own. opencode has no such directory and receives the same text
      # concatenated into AGENTS.md, which is why the text lives in Nix rather
      # than here.
      rules = import ./_agent-rules.nix { inherit lib; };

      # Shared with opencode, which receives it as the head of AGENTS.md.
      context = import ./_agent-context.nix;
      settings =  {
        includeCoAuthoredBy = false;
        feedbackSurveyRate = 0;

        # Registration lives here, not in programs.claude-code.hooks: that option
        # only drops the file into ~/.claude/hooks/ and never registers it.
        hooks.PostToolUse = [
          {
            matcher = "Write|Edit";
            hooks = [
              {
                type = "command";
                command = "${proseLint}/bin/prose-lint";
              }
            ];
          }
        ];
        statusLine = {
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
          type = "command";
        };

      };

    };
  };
}

