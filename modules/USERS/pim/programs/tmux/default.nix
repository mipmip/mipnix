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

      # ---- custom bindings registry ---------------------------------------
      #
      # A binding is declared once here and emitted twice: as the `bind` line
      # that binds the key, and as an entry in the `prefix + ?` menu. Both
      # emitters read the same fields, so the menu cannot drift from the keys.
      #
      # `group` splits the menu: "tools" launches an application, "tmux" nudges
      # tmux itself, and a separator is drawn between the two.
      #
      # Only bindings this config declares belong here. tmux's own defaults,
      # tmux-sensible, and the defaults that gpakosz's `_apply_bindings` pass
      # rewrites in place stay out, as does `u` (urlview): the plugin binds that
      # key itself from an async `run-shell` with its own store paths, so
      # listing it would mean copying plugin internals and racing the plugin.
      customBinds = [
        { group = "tools"; key = "S";   desc = "smug session picker";
          cmd = "popup -E smg"; }
        { group = "tools"; key = "G";   desc = "huphop repo switcher";
          cmd = "popup -E -w 80% -h 80% 'hup tui --mode multiplex --flatlist --filter'"; }
        { group = "tools"; key = "T";   desc = "tj pane watchlist";
          cmd = "popup -E -w 80% -h 80% 'tj --columns --sort-activity --no-sound --no-notify --picker'"; }
        { group = "tools"; key = "B";   desc = "beans task TUI";
          cmd = "popup -E -d '#{pane_current_path}' -w 90% -h 90% 'beans-tui-popup'"; }
        { group = "tools"; key = "D";   desc = "beandex, beans across repos";
          cmd = "popup -E -w 90% -h 90% 'beandex'"; }
        { group = "tools"; key = "H";   desc = "nebula host ssh";
          cmd = "popup -E -w 60% -h 60% 'nebula-ssh'"; }
        { group = "tools"; key = "R";   desc = "dirty repo scanner";
          cmd = "popup -E -w 80% -h 80% 'drs --multiplex'"; }
        { group = "tools"; key = "P";   desc = "shell at the pane path";
          cmd = "display-popup -d '#{pane_current_path}'"; }
        # No wrapper: spg walks up from its working directory for openspec/ and
        # offers its project picker when there is none, so nothing flashes past
        # in a directory that has no project.
        { group = "tools"; key = "A";   desc = "specgetty, openspec projects";
          cmd = "popup -E -d '#{pane_current_path}' -w 90% -h 90% 'spg'"; }

        { group = "tmux";  key = "s";   desc = "session and window tree";
          cmd = "choose-tree -sZ -O name"; }
        { group = "tmux";  key = "Tab"; desc = "last window";
          cmd = "last-window"; }
        { group = "tmux";  key = ";";   desc = "last pane, zoomed";
          cmd = "last-pane -Z"; }
        { group = "tmux";  key = "b";   desc = "toggle the status bar";
          cmd = ''run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"''; }
        { group = "tmux";  key = "O";   desc = "open the pane path in files";
          cmd = "run-shell 'nohup open #{pane_current_path} >/dev/null 2>&1 &'"; }
      ];

      # Two descriptions tmux cannot represent, both failing silently rather
      # than loudly, so they are caught here instead:
      #   - a leading `-` is parsed as a flag, and is also tmux's marker for an
      #     unselectable entry;
      #   - an apostrophe closes the single-quoted menu name early, which
      #     swallows the entries after it.
      checkedBinds =
        let
          bad = lib.filter
            (b: lib.hasPrefix "-" b.desc || lib.hasInfix "'" b.desc)
            customBinds;
        in if bad == [ ]
           then customBinds
           else throw ("tmux bind registry: description for key "
                       + (lib.head bad).key
                       + " must not start with '-' or contain an apostrophe");

      # `;` is tmux's command separator and has to arrive escaped. `\;` is right
      # for a bind line; in the menu's key column only the single-quoted `'\;'`
      # form survives. Bare `;`, `\;`, `';'`, `";"` and `"\;"` all truncate the
      # display-menu command at that argument, silently dropping every entry
      # after it. Measured on tmux 3.6a, see the change's design.md.
      escKey = key: if key == ";" then "\\;" else key;

      bindLine = b: "bind ${escKey b.key} ${b.cmd}";

      # Keys are padded so the descriptions line up in the menu.
      padKey = key:
        let n = 5 - builtins.stringLength key;
        in key + lib.concatStrings (lib.genList (_: " ") (if n > 0 then n else 1));

      # display-menu takes (name, key, command) triples, and renders a lone
      # empty name as a separator line. The command goes in a `{ }` block so
      # tmux keeps it verbatim: several of these carry `#{pane_current_path}`,
      # which a double-quoted argument would expand once at config-parse time
      # and freeze to whatever pane was current then.
      menuItem = b: "'${padKey b.key}${b.desc}' '${escKey b.key}' { ${b.cmd} }";

      inGroup = g: lib.filter (b: b.group == g) checkedBinds;

      bindLines = lib.concatMapStringsSep "\n" bindLine checkedBinds;

      bindsMenu =
        "bind ? display-menu -T ' custom bindings ' -x C -y C \\\n  "
        + lib.concatStringsSep " \\\n  "
            ((map menuItem (inGroup "tools"))
             ++ [ "''" ]
             ++ (map menuItem (inGroup "tmux")));
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

        # The server keeps the environment it was started with, which here has no
        # WAYLAND_DISPLAY at all. Programs in a pane then fall back to the
        # default `wayland-0` socket, while this session's is `wayland-1`, so
        # they conclude there is no Wayland session. That is what makes clipboard
        # tools report themselves missing while installed: atotto/clipboard (used
        # by beans) only considers wl-copy when WAYLAND_DISPLAY is set, and
        # otherwise falls through to xclip/xsel, which are installed nowhere.
        # `-a` appends, keeping tmux's default list.
        set -ga update-environment WAYLAND_DISPLAY

        #COPYPASTE
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi V send -X select-line
        # By store path, as nautilus-copy-path does: no PATH dependency and no
        # need for wl-clipboard to be in systemPackages. Replaces xclip, an X11
        # tool that is installed on no host here, so every yank failed silently.
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel '${pkgs.wl-clipboard}/bin/wl-copy'

        unbind C-a

        # Every custom binding below comes from the registry in the `let` block
        # above, which also generates the `prefix + ?` menu listing them.
        ${bindLines}

        # Replaces tmux's raw `list-keys` on `?` with a navigable menu of the
        # registry: arrows move, Enter fires, Escape closes, and each entry's
        # accelerator is the key it is bound to.
        ${bindsMenu}


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

        if '[ -f ~/.tmux/gpakosz.cf ]' 'source ~/.tmux/gpakosz.cf'
        run 'cat ~/.tmux/gpakosz.sh | sh -s _apply_configuration'

        ######### THEME  ##########
        set-window-option -g window-active-style bg=${config.mip.theme.colors.bg.active}
        set-window-option -g window-style bg='${config.mip.theme.colors.bg.inactive}'
      '';
    };
  };
}
