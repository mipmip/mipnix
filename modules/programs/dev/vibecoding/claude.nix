{ inputs, ... } : {

  flake.modules.homeManager.vibecoding-claude-code-config = { unstable, ... }: {

    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      commands = import ./_cc-commands.nix;
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
        statusLine = {
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
          type = "command";
        };

      };

    };
  };
}

