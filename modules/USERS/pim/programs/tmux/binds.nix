{ ... }:
{
  # Custom tmux bindings. Only the bindings this configuration declares belong
  # here. tmux's own defaults, tmux-sensible, the defaults that gpakosz's
  # `_apply_bindings` pass rewrites in place, and keys a plugin binds for
  # itself stay out: urlview binds `u` from its own async run-shell with its
  # own store paths, so listing it would mean copying plugin internals and
  # racing the plugin.
  #
  # `group` splits the prefix + ? menu: "tools" launches an application, "tmux"
  # nudges tmux itself, and a separator is drawn between the two.
  flake.hotkeys = [

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "S"; desc = "smug session picker";
      action = "popup -E smg"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "G"; desc = "hip repo switcher";
      action = "popup -E -w 80% -h 80% 'hip tui --mode multiplex --flatlist --filter'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "T"; desc = "tj pane watchlist";
      action = "popup -E -w 80% -h 80% 'tj --columns --sort-activity --no-sound --no-notify --picker'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "B"; desc = "beans task TUI";
      action = "popup -E -d '#{pane_current_path}' -w 90% -h 90% 'beans-tui-popup'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "D"; desc = "beandex, beans across repos";
      action = "popup -E -w 90% -h 90% 'beandex'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "H"; desc = "nebula host ssh";
      action = "popup -E -w 60% -h 60% 'nebula-ssh'"; }

    # A toggle, but not the float's kind: the session behind this popup
    # outlives the popup, so "does the session exist" cannot tell open from
    # close. What can is the session the pressing client is attached to, which
    # is the same test the float's width keys use. Inside the popup the key
    # arrives from the popup's own client, so it detaches and the popup closes.
    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "M"; desc = "nebula monitor, nbping and updo";
      action = ''if -F '#{==:#{session_name},_nbmon}' detach-client "run-shell -b 'nebula-monitor open'"''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "R"; desc = "dirty repo scanner";
      action = "popup -E -w 80% -h 80% 'drs --multiplex'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "P"; desc = "shell at the pane path";
      action = "display-popup -d '#{pane_current_path}'"; }

    # No wrapper: spg walks up from its working directory for openspec/ and
    # offers its project picker when there is none, so nothing flashes past in
    # a directory that has no project.
    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "A"; desc = "specgetty, openspec projects";
      action = "popup -E -d '#{pane_current_path}' -w 90% -h 90% 'spg'"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "F"; desc = "float the pane in a popup";
      action = "run-shell -b 'tmux-float toggle'"; }

    # `f` stays tmux's find-window -Z, which is worth more than the mnemonic.
    #
    # The width keys are conditional: they act only while the popup's own
    # client is attached to the float session, and fall through to what they
    # were bound to otherwise. `+` had nothing, `-` had tmux's delete-buffer.
    #
    # Both are kept out of the prefix + ? menu. They do nothing outside the
    # float, so a flat list would invite firing them for no effect, and a menu
    # row for `-` would be rendered dim and unselectable anyway, because the row
    # name begins with the key.
    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "+"; desc = "float wider"; menu = false;
      action = ''if -F '#{==:#{session_name},_float}' "run-shell -b 'tmux-float resize +10'"''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "-"; desc = "float narrower"; menu = false;
      action = ''if -F '#{==:#{session_name},_float}' "run-shell -b 'tmux-float resize -10'" delete-buffer''; }

    # Closes the monitor popup, and does nothing anywhere else. A chord rather
    # than a prefixed entry, which is what puts it in tmux's root table: inside
    # the popup Escape should close the thing in front, the way it does in
    # every other popup here.
    #
    # It takes the key away from nbping, whose own Escape quits it. That is the
    # point: quitting the tool loses the history the popup exists to keep, and
    # leaves a dead pane behind.
    #
    # Out of the menu for the same reason the float's width keys are: it means
    # nothing outside the popup.
    { kind = "chord"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "Escape"; desc = "close the nebula monitor popup";
      menu = false;
      action = ''if -F '#{==:#{session_name},_nbmon}' detach-client 'send-keys Escape' ''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "s"; desc = "session and window tree";
      action = "choose-tree -sZ -O name"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "Tab"; desc = "last window";
      action = "last-window"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = ";"; desc = "last pane, zoomed";
      action = "last-pane -Z"; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "b"; desc = "toggle the status bar";
      action = ''run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tmux"; key = "O"; desc = "open the pane path in files";
      action = "run-shell 'nohup open #{pane_current_path} >/dev/null 2>&1 &'"; }
  ];
}
