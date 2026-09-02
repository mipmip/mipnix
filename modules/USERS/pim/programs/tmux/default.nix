{
inputs,
...
}:
{
  flake.modules.homeManager.pim-tmux = { pkgs, config, lib, ... }:
    let
      # Launcher for the `prefix + B` tmux popup. Preflights for a beans project
      # (.beans.yml searched upward — NOT `beans check`'s exit code, which is 0
      # even with no project) and, on failure, shows the CWD + `beans check`
      # output and waits for a keypress instead of letting the -E popup silently
      # flash-close. Happy path runs `beans tui` and closes on a clean quit.
      beans-tui-popup = pkgs.writeShellScriptBin "beans-tui-popup" ''
        echo "CWD: ''$PWD"

        # Search upward for the beans project marker (.beans.yml).
        find_project() {
          d="''$PWD"
          while [ "''$d" != "/" ]; do
            [ -f "''$d/.beans.yml" ] && return 0
            d="''$(dirname "''$d")"
          done
          return 1
        }

        if find_project; then
          beans tui
          rc=''$?
          if [ "''$rc" -ne 0 ]; then
            echo
            echo "beans tui exited with code ''$rc"
            echo "---- beans check ----"
            beans check
            echo
            echo "Press any key to close"
            read -rn1
          fi
        else
          echo "No beans project (.beans.yml) found at or above this directory."
          echo "---- beans check ----"
          beans check
          echo
          echo "Press any key to close"
          read -rn1
        fi
      '';

      # Launcher for the `prefix + H` tmux popup: pick a nebula host with fzf and
      # SSH into it as a window in a dedicated `nebula-prive` session (create-or-
      # select, so re-picking a host reconnects rather than duplicating). Host list
      # is baked from the single-source flake.nebulaNodes registry via
      # self.lib.nebulaHosts. Escape / empty selection closes the popup, creating
      # nothing.
      nebula-ssh = pkgs.writeShellScriptBin "nebula-ssh" ''
        set -eu
        hosts="${lib.concatStringsSep "\n" inputs.self.lib.nebulaHosts}"
        choice="''$(printf '%s\n' "''$hosts" | ${pkgs.fzf}/bin/fzf --reverse --prompt='ssh > ' --header='nebula hosts')" || exit 0
        [ -z "''$choice" ] && exit 0
        name="''${choice%% *}"
        ip="''${choice##* }"
        sess="nebula-prive"
        tmux="${pkgs.tmux}/bin/tmux"
        if ! "''$tmux" has-session -t "=''$sess" 2>/dev/null; then
          "''$tmux" new-session -d -s "''$sess" -n "''$name" "ssh pim@''$ip"
        elif ! "''$tmux" list-windows -t "=''$sess" -F '#W' | grep -qx "''$name"; then
          "''$tmux" new-window -d -t "=''$sess" -n "''$name" "ssh pim@''$ip"
        fi
        "''$tmux" switch-client -t "=''$sess:''$name"
      '';

      # switch_command target for `drs --multiplex` (bound to `prefix + R`). drs
      # runs this with the selected repo's directory when Enter is pressed. Derives
      # the window name from the dir basename and does create-or-select into a
      # dedicated `dirtyrepos` session, so re-picking a repo reuses its window
      # rather than duplicating it. Repos that share a basename intentionally
      # collapse onto one window.
      #
      # The switch targets the window by its id (@N), NEVER by "session:name":
      # repo basenames like "mip.rs" contain a dot, and tmux would parse the
      # target "=dirtyrepos:mip.rs" as window "mip", pane "rs" -> "can't find
      # pane: rs" -> switch fails. A window-id target is dot-safe.
      drs-switch = pkgs.writeShellScriptBin "drs-switch" ''
        set -eu
        dir="''${1:-}"
        [ -z "''$dir" ] && exit 0
        name="''$(basename "''$dir")"
        sess="dirtyrepos"
        tmux="${pkgs.tmux}/bin/tmux"
        win=""
        if "''$tmux" has-session -t "=''$sess" 2>/dev/null; then
          while IFS=' ' read -r id wname; do
            [ "''$wname" = "''$name" ] && { win="''$id"; break; }
          done < <("''$tmux" list-windows -t "=''$sess" -F '#{window_id} #{window_name}')
          [ -z "''$win" ] && win="''$("''$tmux" new-window -d -t "=''$sess" -n "''$name" -c "''$dir" -P -F '#{window_id}')"
        else
          win="''$("''$tmux" new-session -d -s "''$sess" -n "''$name" -c "''$dir" -P -F '#{window_id}')"
        fi
        "''$tmux" switch-client -t "''$win"
      '';
    in
    {
    home.file = {
      ".tmux" = {
        source = ./tmux;
        recursive = true;
      };
    };

    home.packages = with pkgs; [
      urlscan
      beans-tui-popup
      nebula-ssh
      drs-switch
    ];

    programs.tmux = {
      enable = true;
      sensibleOnTop = true;
      newSession = false;
      historyLimit = 5000;
      plugins = [
        pkgs.tmuxPlugins.urlview
      ];

      extraConfig = ''
        set -s escape-time 10                     # faster command sequences
        set -sg repeat-time 200                   # increase repeat timeout

        set -s focus-events on

        set -g base-index 1           # start windows numbering at 1
        setw -g pane-base-index 1     # make pane numbering consistent with windows

        setw -g automatic-rename off  # rename window to reflect current program
        set -g renumber-windows on    # renumber windows when a window is closed

        set -g set-titles on          # set terminal title
        set-option -g set-titles-string '#S'

        set -g display-panes-time 800 # slightly longer pane indicators display time
        set -g display-time 1000      # slightly longer status messages display time

        set -g status-interval 300     # redraw status line in seconds

        # ACTIVITY
        set -g monitor-activity off
        set -g visual-activity off

        #COPYPASTE
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi V send -X select-line
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

        unbind C-a
        bind Tab last-window        # move to last active window

        bind s choose-tree -sZ -O name
        bind S popup -E smg
        bind G popup -E -w 80% -h 80% 'hup tui --mode multiplex --flatlist --filter'
        bind T popup -E -w 80% -h 80% 'tj --columns --sort-activity --no-sound --no-notify --picker'
        bind B popup -E -d '#{pane_current_path}' -w 90% -h 90% 'beans-tui-popup'
        bind D popup -E -w 90% -h 90% 'beandex'
        bind H popup -E -w 60% -h 60% 'nebula-ssh'
        bind R popup -E -w 80% -h 80% 'drs --multiplex'
        bind P display-popup -d '#{pane_current_path}'
        bind O run-shell 'nohup open #{pane_current_path} >/dev/null 2>&1 &'


        # START WITH MOUSE MODE ENABLED
        set -g mouse on

        ## THIS WORKED FOR ST but not for alacritty
        # set -g default-terminal "screen-256color"
        # set -sa terminal-overrides ',xterm-256color:RGB'

        set -g default-terminal "$TERM"
        set -ag terminal-overrides ",$TERM:Tc"
        setw -g xterm-keys on

        # FIX HOME END KEYS
        bind-key -n Home send Escape "OH"
        bind-key -n End send Escape "OF"

        bind-key a send Escape "OH"
        set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
        setw -q -g utf8 on

        bind \; last-pane -Z

        # Toggle status bar visibility
        bind b run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"

        if '[ -f ~/.tmux/gpakosz.cf ]' 'source ~/.tmux/gpakosz.cf'
        run 'cat ~/.tmux/gpakosz.sh | sh -s _apply_configuration'

        ######### THEME  ##########
        set-window-option -g window-active-style bg=${config.mip.theme.colors.bg.active}
        set-window-option -g window-style bg='${config.mip.theme.colors.bg.inactive}'
      '';
    };
  };
}
