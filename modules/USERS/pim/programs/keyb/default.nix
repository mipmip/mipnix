{
inputs,
...
}:
{
  # The two tmux keys that open the cheatsheet. They are registry entries like
  # every other tmux binding, so they appear in the `prefix + ?` menu too.
  #
  # `K` opens the sheet for whatever is running in the pane, `k` opens the lot.
  #
  # K goes through run-shell rather than binding display-popup directly:
  # display-popup does NOT expand `#{}` inside its shell-command argument, so
  # the launcher was handed the literal string `#{pane_current_command}` and
  # fell back to the full sheet every time. run-shell does expand it, against
  # the pane the key was pressed in, and then opens the popup with the answer.
  #
  # Both end in a display-popup, which is why they are reachable from the
  # menu: the menu is a display-menu, and a popup opened from inside a
  # `display-popup -E` would exit 0 and do nothing.
  flake.hotkeys = [
    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "K"; desc = "hotkeys for this pane";
      action =
        ''run-shell "tmux display-popup -E -w 80% -h 80% 'keyb-popup #{pane_current_command}'"''; }

    { kind = "prefixed"; app = "tmux"; target = "tmux"; scopes = [ "terminal" ];
      group = "tools"; key = "k"; desc = "hotkeys, everything";
      action = "popup -E -w 80% -h 80% 'keyb-popup --full'"; }
  ];

  flake.modules.homeManager.pim-keyb = { pkgs, lib, ... }:
    let
      hk = inputs.self.lib.hotkeys;
      all = hk.documented inputs.self.hotkeys;

      # The neovim keymaps are 56 entries and swamp every other section, so
      # they stay out of the sheets that list everything. They keep their own
      # per-application sheet, which is the one `prefix + K` opens from a pane
      # running neovim.
      entries = hk.withoutTarget "nvim" all;

      sheet = name: es:
        pkgs.writeText "keyb-${name}.json" (builtins.toJSON (hk.toKeyb es));

      # One file per application, plus the full one. keyb has no filter flag,
      # but it does take a hotkey file path, so the split is what makes a
      # context-aware popup possible without touching keyb itself.
      perApp = lib.listToAttrs (map
        (app: lib.nameValuePair
          ".config/keyb/${hk.keybSlug app}.json"
          { source = sheet (hk.keybSlug app) (lib.filter (e: e.app == app) all); })
        (hk.apps all));

      # keyb colours only the chrome: the prompt, the cursor, filter matches,
      # the counter, the placeholder and the border. The list body and the
      # section headings are not configurable, and the headings are rendered
      # bold with no foreground (ui/list/list.go), so bold is all they can be.
      # Values are Gruvbox Material, matching the ghostty theme.
      config = pkgs.writeText "keyb-config.yml" ''
        settings:
          border: rounded
          padding: 1
          sep_width: 4
          prompt: "keys > "
          placeholder: "type to filter"
        color:
          prompt: "#d8a657"
          cursor_fg: "#1d2021"
          cursor_bg: "#89b482"
          filter_fg: "#e78a4e"
          counter_fg: "#928374"
          placeholder_fg: "#928374"
          border_color: "#7daea3"
      '';

      # Maps a pane's command to its sheet. The command is passed in by tmux on
      # the bind line rather than read here: by the time this runs, the current
      # pane is the popup's own.
      keyb-popup = pkgs.writeShellScriptBin "keyb-popup" ''
        set -eu
        # termenv gives up on colour when it cannot detect support, which is
        # what a popup looks like to it.
        export CLICOLOR_FORCE=1
        dir="''$HOME/.config/keyb"
        arg="''${1:-}"

        if [ "''$arg" = "--full" ]; then
          exec ${pkgs.keyb}/bin/keyb -k "''$dir/full.json"
        fi

        case "''$arg" in
          nvim|vim|vi)      file="''$dir/neovim.json" ;;
          fish|zsh|bash|sh) file="''$dir/shell.json" ;;
          *)                file="''$dir/''$arg.json" ;;
        esac

        # Anything without a sheet of its own gets the full one, so the popup
        # never opens empty and never fails to open.
        [ -f "''$file" ] || file="''$dir/full.json"

        exec ${pkgs.keyb}/bin/keyb -k "''$file"
      '';
    in
    {
      home.packages = [ pkgs.keyb keyb-popup ];

      home.file = perApp // {
        ".config/keyb/full.json".source = sheet "full" entries;
        ".config/keyb/config.yml".source = config;
      };
    };
}
