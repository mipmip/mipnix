{ ... }:
{
  # Keys of applications this repository does not configure, plus shell words
  # defined elsewhere. Nothing here is bound by anything in this flake, so
  # every entry carries `target = null` and reaches the cheatsheets only.
  #
  # This is the class that grows fastest, which is why it is a flat data file
  # rather than a module with logic in it: adding a reminder is adding a line.
  flake.hotkeys = [

    # --- Zathura ------------------------------------------------------------
    { kind = "sequence"; app = "Zathura"; scopes = [ "desktop" ];
      seq = "Tab"; desc = "Show paragraph outline"; }

    # --- Neo-tree -----------------------------------------------------------
    { kind = "chord"; app = "Neo-tree"; scopes = [ "terminal" ];
      mods = [ "shift" ]; key = "Y"; desc = "Copy file paths to clipboard"; }

    # --- MyHotKeys ----------------------------------------------------------
    { kind = "chord"; app = "MyHotKeys"; scopes = [ "desktop" ];
      mods = [ "ctrl" ]; key = "F"; desc = "search for key binding"; }
    { kind = "chord"; app = "MyHotKeys"; scopes = [ "desktop" ];
      mods = [ "alt" ]; key = "1"; desc = "Page 1 (idem for page 2-n)"; }

    # --- Firefox ------------------------------------------------------------
    { kind = "chord"; app = "Firefox"; scopes = [ "desktop" ];
      mods = [ "ctrl" ]; key = "K"; desc = "Focus address bar"; }

    # --- Inkscape -----------------------------------------------------------
    { kind = "sequence"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      seq = "S"; desc = "Select object"; }
    { kind = "sequence"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      seq = "N"; desc = "Select nodes"; }
    { kind = "chord"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      mods = [ "ctrl" "shift" ]; key = "D"; desc = "Document Properties"; }
    { kind = "chord"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      mods = [ "ctrl" "shift" ]; key = "E"; desc = "Export to PNG"; }
    { kind = "chord"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      mods = [ "ctrl" "shift" ]; key = "N"; desc = "New layer"; }
    { kind = "chord"; app = "Inkscape Shortcuts"; scopes = [ "desktop" ];
      mods = [ "ctrl" ]; key = "M"; desc = "Move selection to layer"; }

    # --- Gimp ---------------------------------------------------------------
    { kind = "sequence"; app = "Gimp"; scopes = [ "desktop" ];
      seq = "R"; desc = "Select rectangle"; }
    { kind = "sequence"; app = "Gimp"; scopes = [ "desktop" ];
      seq = "U"; desc = "Magic selection"; }
    { kind = "chord"; app = "Gimp"; scopes = [ "desktop" ];
      mods = [ "shift" ]; key = "C"; desc = "Crop tool"; }

    # --- git ----------------------------------------------------------------
    # Abbreviations from the fish git plugin, not defined in this repository.
    # Listed so they can be looked up, without this flake claiming to bind them.
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "ga"; desc = "git add"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gcl"; desc = "git clone --recurse-submodules"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gco"; desc = "git checkout"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gsb"; desc = "git status"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gd"; desc = "git diff"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gc"; desc = "git commit"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gp"; desc = "git push"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gl"; desc = "git pull"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gf"; desc = "git fetch"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gb"; desc = "git branch"; }
    { kind = "word"; app = "git"; scopes = [ "terminal" ]; word = "gm"; desc = "git merge"; }

    # --- sc-im --------------------------------------------------------------
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "y+y"; desc = "Yank Cell"; }
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "p"; desc = "Simple paste"; }
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "P+c"; desc = "Paste, refs are adjusted"; }
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "braceleft braceright"; desc = "Left align / Right align"; }
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "a+a"; desc = "Resize column to fit content"; }
    { kind = "sequence"; app = "sc-im"; scopes = [ "terminal" ];
      seq = "d+r"; desc = "Delete row"; }
    { kind = "word"; app = "sc-im"; scopes = [ "terminal" ];
      word = ":fsum"; desc = "sum all above"; }

    # --- Readline -----------------------------------------------------------
    # The pairs stay one entry each, as they read on a cheatsheet: two chords
    # that are only worth remembering together.
    { kind = "sequence"; app = "Readline"; scopes = [ "terminal" ];
      seq = "Alt+b  Alt+f"; desc = "Move backward/forward by word"; }
    { kind = "sequence"; app = "Readline"; scopes = [ "terminal" ];
      seq = "Alt+w  Alt+d"; desc = "Kill word backward/forward"; }
    { kind = "sequence"; app = "Readline"; scopes = [ "terminal" ];
      seq = "Ctrl+k  Ctrl+u"; desc = "Kill to end of line/beginning of line"; }
    { kind = "chord"; app = "Readline"; scopes = [ "terminal" ];
      mods = [ "ctrl" ]; key = "Y"; desc = "Yank from kill ring"; }
    { kind = "chord"; app = "Readline"; scopes = [ "terminal" ];
      mods = [ "alt" ]; key = "Y"; desc = "Cycle through kill ring history (after Ctrl+y)"; }
    { kind = "chord"; app = "Readline"; scopes = [ "terminal" ];
      mods = [ "alt" ]; key = "T"; desc = "Transpose word"; }
    # Carried over as it stood in myhotkeys.json, which documents this on the
    # same key as "Transpose word". readline's upcase-word is Alt+u, so one of
    # the two is likely wrong, but migrating is not the moment to decide which.
    { kind = "chord"; app = "Readline"; scopes = [ "terminal" ];
      mods = [ "alt" ]; key = "T"; desc = "Upper forward word"; }
    { kind = "chord"; app = "Readline"; scopes = [ "terminal" ];
      mods = [ "ctrl" ]; key = "slash"; desc = "Cycle through the undo list"; }

    # --- tmux, bound by a plugin --------------------------------------------
    # urlview binds this key itself from its own run-shell, so it is documented
    # here rather than registered on the tmux target.
    { kind = "prefixed"; app = "tmux"; scopes = [ "terminal" ];
      key = "u"; desc = "Urlview"; }

    # --- Fish ---------------------------------------------------------------
    { kind = "chord"; app = "Fish"; scopes = [ "terminal" ];
      mods = [ "alt" ]; key = "E"; desc = "Open prompt in $EDITOR"; }

    # --- Claude Code --------------------------------------------------------
    { kind = "chord"; app = "Claude Code"; scopes = [ "terminal" ];
      mods = [ "ctrl" ]; key = "G"; desc = "Open prompt in $EDITOR"; }
  ];
}
