{
  flake.modules.homeManager.pim-atuin = { unstable, lib, ... } : {

    programs.fish.interactiveShellInit = lib.mkAfter ''
      set -e ATUIN_TMUX_POPUP
      function _atuin_ai_resume_popup
          if test (_atuin_tmux_popup_check) -ne 1
              _atuin_ai_resume
              return
          end

          set -l tmpdir (mktemp -d)
          set -l result_file "$tmpdir/result"
          set -l query (commandline -b | string replace -a "'" "'\\'''")
          set -q ATUIN_TMUX_POPUP_WIDTH; or set -l ATUIN_TMUX_POPUP_WIDTH 80%
          set -q ATUIN_TMUX_POPUP_HEIGHT; or set -l ATUIN_TMUX_POPUP_HEIGHT 60%
          tmux display-popup -d (pwd) -w "$ATUIN_TMUX_POPUP_WIDTH" -h "$ATUIN_TMUX_POPUP_HEIGHT" -E -E -- \
              sh -c "PATH='$PATH' ATUIN_SESSION='$ATUIN_SESSION' ATUIN_SHELL=fish ATUIN_QUERY='$query' atuin threads resume --shell-widget --keymap-mode=emacs 2>'$result_file'"
          set -l ATUIN_H (cat "$result_file" 2>/dev/null | string trim | string collect)
          command rm -rf "$tmpdir"

          if string match --quiet '__atuin_accept__:*' -- "$ATUIN_H"
              commandline -r (string replace "__atuin_accept__:" "" -- "$ATUIN_H" | string collect)
              commandline -f repaint
              commandline -f execute
              return
          else if test -n "$ATUIN_H"
              commandline -r "$ATUIN_H"
          end
          commandline -f repaint
      end

      bind ctrl-] _atuin_ai_resume_popup
    '';

    programs.atuin = {
      enable = true;
      package = unstable.atuin;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      daemon = {
        enable = true;
      };
      settings = {
        auto_sync = true;
        daemon.sync_frequency = 300;
        sync_address = "https://atuin.tools.technative.cloud";
        search_mode = "fuzzy";
        dialect = "us";
        filter_mode = "host";
        ui = {
          columns = ["time" "host" "directory" "command"];
        };
        tmux = {
          enabled = true;
          width = "80%";
          height = "60%";
        };
        common_prefix = [
          "ls"
          "cd"
          "grep"
          "nvim"
        ];
        common_subcommands = [
          "bmc"
          "race"
          "jj"
          "git"
          "nix"
          "npm"
        ];
        secrets_filter = true;
        history_filter = [
          "^export.*KEY"
          "^export.*TOKEN"
        ];

        threads = {
          capture = true;
          capture_tools = true;
          filter_mode = "directory";
        };
      };
    };
  };
}
