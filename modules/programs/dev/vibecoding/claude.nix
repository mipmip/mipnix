{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config =
    { pkgs, lib, unstable, ... }:
    let
      # The PostToolUse checker. Referenced by store path, never by a bare
      # interpreter name: programs.claude-code.hooks writes its files without an
      # executable bit, and naming `python3` in the command would make the hook
      # die silently in any shell that lacks it.
      proseLint = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".prose-lint;

      # One source of truth for the word list: the same JSON the linter reads is
      # rendered into the rule file, so the two can never drift apart.
      fillerWords = builtins.fromJSON (
        builtins.readFile ../../../../packages/prose-lint/filler-words.json
      );
      renderWords = words: lib.concatMapStringsSep "\n" (w: "- ${w}") words;
    in
    {

    # The checker is also a tool you can run yourself: `prose-lint FILE...`.
    # Same derivation the hook uses, so there is one of it, not two.
    home.packages = [ proseLint ];

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      commands = import ./_cc-commands.nix;

      # Writing rules, one file per concern. Every markdown file in
      # ~/.claude/rules/ is loaded as memory automatically, which is why these
      # do not live in the `context` blob below.
      rules = {
        prose-typography = ''
          # Prose typography

          These marks are never wanted. Not in a blog post, not in a spec, not in
          a commit message, and in neither Dutch nor English. There is no context
          that calls for them, so there is no exception to weigh.

          - The em dash `—` (U+2014). Name the relation instead ("because",
            "but", "for example"), use a comma, a colon or parentheses, or write
            two sentences.
          - The en dash `–` (U+2013). In a range a plain hyphen does the job.
            Anywhere else, rewrite.
          - A spaced double hyphen used as a dash. Same rule as the em dash.
          - Curly quotation marks. Use straight quotes.

          Dashes and hyphens inside code blocks, inline code, commands, paths and
          URLs are not prose and are left alone.

          A hook checks this after every write to a prose file and fails the
          write when it finds a hit, so treat it as settled rather than as
          advice.
        '';

        prose-filler-words = ''
          # Filler words

          Use a word from this list only when it carries meaning. Drop it when it
          is a verbal tic. The same word can be either:

          - "dat is eigenlijk niet waar" corrects a claim, so it stays.
          - "dat is eigenlijk best goed" says nothing, so it goes.

          A hook reports these with the sentence they sit in. It does not fail
          the write, because only a reader can tell the two cases apart.

          ## Dutch

          ${renderWords fillerWords.nl}

          ## English

          ${renderWords fillerWords.en}
        '';
      };
      context = ''
        # Git - Commits
        - Never add self-promoting trailers to commit messages. Do NOT include `Co-authored-by: Claude`, `Co-Authored-By: Claude`, `Generated with Claude Code`, or any similar attribution to Claude/Anthropic. Commits are authored by me alone.

        # Markdown - Styleguide
        - When creating a markdown table which is not wider then 90 chars, using space padding to visualy align table borders.


        # RTK - Rust Token Killer

        **Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

        ## Meta Commands (always use rtk directly)

        ```bash
        rtk gain              # Show token savings analytics
        rtk gain --history    # Show command usage history with savings
        rtk discover          # Analyze Claude Code history for missed opportunities
        rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
        ```

        ## Installation Verification

        ```bash
        rtk --version         # Should show: rtk X.Y.Z
        rtk gain              # Should work (not "command not found")
        which rtk             # Verify correct binary
        ```

        ⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

        ## Hook-Based Usage

        All other commands are automatically rewritten by the Claude Code hook.
        Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

        Refer to CLAUDE.md for full command reference.
        '';
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

