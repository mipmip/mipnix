{ lib }:

let

  modifierOrder = [ "ctrl" "ctrl_l" "alt" "shift" "super" ];

  letters = lib.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  digits = lib.stringToCharacters "0123456789";

  functionKeys = lib.genList (i: "F${toString (i + 1)}") 12;

  namedKeys = [
    "Return" "space" "Tab" "Escape" "BackSpace" "Delete" "Insert"
    "Left" "Right" "Up" "Down" "Home" "End" "Prior" "Next" "Print" "Menu"
    "grave" "slash" "backslash" "semicolon" "apostrophe" "comma" "period"
    "minus" "equal" "plus" "bracketleft" "bracketright"
    "braceleft" "braceright" "exclam" "at" "numbersign" "dollar" "percent"
    "asciicircum" "ampersand" "asterisk" "parenleft" "parenright"
    "underscore" "question" "colon" "quotedbl" "less" "greater" "bar"
    "asciitilde"
    "XF86AudioRaiseVolume" "XF86AudioLowerVolume" "XF86AudioMute"
    "XF86AudioMicMute" "XF86AudioNext" "XF86AudioPrev" "XF86AudioPlay"
    "XF86AudioPause" "XF86MonBrightnessUp" "XF86MonBrightnessDown"
  ];

  keysyms = letters ++ digits ++ functionKeys ++ namedKeys;

  isMouseKey = key: lib.hasPrefix "mouse" key;
  isLetter = key: lib.elem key letters;
  isKnownKey = key: lib.elem key keysyms || isMouseKey key;

  # Sorting into a fixed order makes two spellings of the same chord render
  # identically and collide in duplicate detection. The order is per target
  # where a target has a convention of its own: Hyprland configurations read
  # `$mainMod SHIFT`, while gnome and ghostty put shift first.
  normaliseModsIn = order: mods:
    lib.filter (m: lib.elem m mods) order;

  normaliseMods = normaliseModsIn modifierOrder;

  # Display names for the cheatsheet renderers, which never fail: they show
  # whatever the registry holds rather than refusing to describe it.
  displayNames = {
    "Return" = "Return"; "space" = "Space"; "Tab" = "Tab"; "Escape" = "Esc";
    "Left" = "Left"; "Right" = "Right"; "Up" = "Up"; "Down" = "Down";
    "Prior" = "PgUp"; "Next" = "PgDn"; "grave" = "`"; "slash" = "/";
    "backslash" = "\\"; "semicolon" = ";"; "apostrophe" = "'";
    "comma" = ","; "period" = "."; "minus" = "-"; "equal" = "=";
    "plus" = "+"; "bracketleft" = "["; "bracketright" = "]";
    "braceleft" = "{"; "braceright" = "}"; "exclam" = "!"; "at" = "@";
    "numbersign" = "#"; "dollar" = "$"; "percent" = "%";
    "asciicircum" = "^"; "ampersand" = "&"; "asterisk" = "*";
    "parenleft" = "("; "parenright" = ")"; "underscore" = "_";
    "question" = "?"; "colon" = ":"; "quotedbl" = "\"";
    "less" = "<"; "greater" = ">"; "bar" = "|"; "asciitilde" = "~";
    "XF86AudioRaiseVolume" = "Volume Up";
    "XF86AudioLowerVolume" = "Volume Down";
    "XF86AudioMute" = "Mute";
    "XF86AudioMicMute" = "Mic Mute";
    "XF86MonBrightnessUp" = "Brightness Up";
    "XF86MonBrightnessDown" = "Brightness Down";
    "mouse_down" = "Wheel Down";
    "mouse_up" = "Wheel Up";
    "mouse:272" = "Left Mouse";
    "mouse:273" = "Right Mouse";
    "mouse:274" = "Middle Mouse";
  };

  # Per-target vocabulary. `mods` maps a canonical modifier to its spelling;
  # a modifier absent from the set cannot be expressed by that target. `key`
  # renders a canonical keysym. `fail` is false for the cheatsheet renderers,
  # which must describe every entry rather than reject it.
  vocab = {

    hyprland = {
      fail = true;
      mouse = true;
      order = [ "super" "ctrl" "ctrl_l" "alt" "shift" ];
      mods = {
        ctrl = "CTRL"; ctrl_l = "Control_L"; alt = "ALT";
        shift = "SHIFT"; super = "$mainMod";
      };
      # Hyprland matches keysyms case-insensitively. The spellings below are
      # the ones the hand-written binds.conf used, so the generated file reads
      # the way the file it replaces did.
      key = k:
        let aliases = {
          "Return" = "RETURN"; "space" = "SPACE"; "Tab" = "TAB";
          "Escape" = "ESCAPE"; "Left" = "left"; "Right" = "right";
          "Up" = "up"; "Down" = "down";
        };
        in aliases.${k} or k;
      join = mods: key: "${lib.concatStringsSep " " mods}, ${key}";
    };

    gnome = {
      fail = true;
      mouse = false;
      mods = {
        ctrl = "<Control>"; alt = "<Alt>"; shift = "<Shift>"; super = "<Super>";
      };
      key = k: if isLetter k then lib.toLower k else k;
      join = mods: key: "${lib.concatStrings mods}${key}";
    };

    ghostty = {
      fail = true;
      mouse = false;
      mods = {
        ctrl = "ctrl"; alt = "alt"; shift = "shift"; super = "super";
      };
      key = k:
        let
          aliases = {
            "Return" = "enter"; "space" = "space"; "Tab" = "tab";
            "Escape" = "escape"; "BackSpace" = "backspace";
            "Delete" = "delete"; "Insert" = "insert";
            "Left" = "left"; "Right" = "right"; "Up" = "up"; "Down" = "down";
            "Home" = "home"; "End" = "end"; "Prior" = "page_up";
            "Next" = "page_down"; "grave" = "grave_accent";
            "slash" = "slash"; "backslash" = "backslash";
            "semicolon" = "semicolon"; "apostrophe" = "apostrophe";
            "comma" = "comma"; "period" = "period"; "minus" = "minus";
            "equal" = "equal"; "bracketleft" = "left_bracket";
            "bracketright" = "right_bracket";
          };
        in
        if isLetter k then lib.toLower k
        else if lib.elem k digits then k
        else if lib.elem k functionKeys then lib.toLower k
        else aliases.${k} or null;
      join = mods: key: lib.concatStringsSep "+" (mods ++ [ key ]);
    };

    myhotkeys = {
      fail = false;
      mouse = true;
      mods = {
        ctrl = "<CTRL>"; ctrl_l = "<CTRL>"; alt = "<ALT>";
        shift = "<SHIFT>"; super = "<SUPER>";
      };
      key = k: k;
      join = mods: key: "${lib.concatStrings mods}${key}";
    };

    keyb = {
      fail = false;
      mouse = true;
      mods = {
        ctrl = "Ctrl"; ctrl_l = "Ctrl"; alt = "Alt";
        shift = "Shift"; super = "Super";
      };
      key = k: displayNames.${k} or k;
      join = mods: key: lib.concatStringsSep " + " (mods ++ [ key ]);
    };
  };

  entryLabel = entry:
    let
      what =
        if entry.key != null then entry.key
        else if entry.lhs != null then entry.lhs
        else if entry.word != null then entry.word
        else if entry.seq != null then entry.seq
        else "<no key>";
    in
    "${if entry.app == null then "<no app>" else entry.app} ${what}";

  renderChord = targetName: entry:
    let
      t = vocab.${targetName};
      mods = normaliseModsIn (t.order or modifierOrder) entry.mods;
      renderedMods = map
        (m:
          let spelling = t.mods.${m} or null; in
          if spelling != null then spelling
          else if t.fail
          then throw "hotkeys: ${entryLabel entry} uses modifier '${m}', which ${targetName} cannot express"
          else m)
        mods;
      renderedKey =
        if isMouseKey entry.key
        then
          (if t.mouse then t.key entry.key
           else throw "hotkeys: ${entryLabel entry} is a mouse binding, which ${targetName} cannot express")
        else
          let k = t.key entry.key; in
          if k != null then k
          else throw "hotkeys: ${entryLabel entry} uses key '${entry.key}', which ${targetName} cannot express";
    in
    t.join renderedMods renderedKey;

  # How an entry reads in a cheatsheet, whatever its kind.
  displayKey = targetName: entry:
    if entry.kind == "chord" then renderChord targetName entry
    else if entry.kind == "prefixed" then "${entry.prefixLabel} ${entry.key}"
    else if entry.kind == "mapped" then entry.lhs
    else if entry.kind == "word" then entry.word
    else entry.seq;

  forTarget = target: entries: lib.filter (e: e.target == target) entries;

  # What a cheatsheet shows: everything bound or documented, minus the
  # unbindings and minus the family members another entry already covers.
  documented = entries:
    lib.filter (e: e.document && !e.unbind) entries;

  withoutTarget = target: entries: lib.filter (e: e.target != target) entries;

  forScope = scope: entries:
    lib.filter (e: e.scopes == [ ] || lib.elem scope e.scopes) entries;

  apps = entries:
    lib.unique (map (e: e.app) entries);

  byApp = entries:
    lib.listToAttrs (map
      (a: lib.nameValuePair a (lib.filter (e: e.app == a) entries))
      (apps entries));

  # --- cheatsheet emitters ---------------------------------------------------

  # Groups in first-appearance order, so the registry's own ordering decides
  # how a sheet reads rather than an accident of sorting.
  groupsOf = entries:
    let
      ordered = lib.unique (map (e: e.app) entries);
    in
    map (a: { app = a; entries = lib.filter (e: e.app == a) entries; }) ordered;

  # keyb reads a list of sections, each keybind carrying a name and a key. It
  # accepts JSON as well as YAML, which is what this generates: the escaping
  # rules are then builtins.toJSON's problem rather than this file's.
  #
  # No section carries keyb's `prefix` field. It looks like a fit for tmux
  # until the tmxa and tmxb aliases are taken into account: they switch the
  # running prefix between Ctrl+A and Ctrl+B, so a written prefix would be
  # wrong half the time and wrong silently. The prefix is part of the rendered
  # key instead.
  toKeyb = entries:
    map
      (g: {
        name = g.app;
        keybinds = map
          (e: { name = e.desc; key = displayKey "keyb" e; })
          g.entries;
      })
      (groupsOf (documented entries));

  # A file name for one application's sheet.
  keybSlug = app:
    lib.toLower (lib.replaceStrings [ " " "/" ] [ "-" "-" ] app);

  # myhotkeys interpolates these strings straight into GtkBuilder XML, so a
  # stray `<` is fatal rather than ugly: its parse_accelerator escapes only the
  # modifier tokens it knows (<Ctrl>, <Super>, ...), and anything else with an
  # angle bracket reaches GtkBuilder as a tag. `<Leader>w` from the neovim
  # keymaps killed the app outright that way.
  xmlEscape = lib.replaceStrings [ "&" "<" ">" ] [ "&amp;" "&lt;" "&gt;" ];

  # Everything but a `word` goes in the `key` field, even when it is not a
  # valid accelerator and GTK warns about it. The field decides the widget:
  # `key` becomes a GtkShortcutsShortcut and `command` a plain GtkBox. Only the
  # first counts toward the height GtkShortcutsSection uses to split the sheet
  # into columns and pages, so filling the sheet with commands makes it compute
  # almost no height and render as one page taller than the screen.
  #
  # A chord renders with the modifier tokens parse_accelerator recognises, so
  # it must not be escaped here: escaping would hide the tokens from it and
  # leave the literal text on screen. Every other kind is free text and is
  # escaped, which is what stops `<Leader>w` from being read as a tag.
  myhotkeysKey = e:
    if e.kind == "chord"
    then renderChord "myhotkeys" e
    else xmlEscape (displayKey "myhotkeys" e);

  toMyhotkeys = entries:
    map
      (g: {
        name = xmlEscape g.app;
        shortcuts = map
          (e:
            { description = xmlEscape e.desc; }
            // (if e.kind == "word"
                then { command = xmlEscape e.word; }
                else { key = myhotkeysKey e; }))
          g.entries;
      })
      (groupsOf (documented entries));

  # --- ghostty emitter -------------------------------------------------------

  toGhostty = entries:
    map (e: "${renderChord "ghostty" e}=${e.action}") (forTarget "ghostty" entries);

  # --- gnome emitter ---------------------------------------------------------

  # A gnome entry's action is the full dconf path of the key it binds, so the
  # emitter can put it back in the right section without a second field. An
  # entry carrying a `command` is a custom keybinding instead: gnome stores
  # those as a path of their own holding a binding, a command and a name, and
  # the list of those paths is derived here rather than restated.
  toGnome = entries:
    let
      bound = forTarget "gnome" entries;
      named = lib.filter (e: e.command == null) bound;
      custom = lib.filter (e: e.command != null) bound;

      dirOf = path: lib.concatStringsSep "/" (lib.init (lib.splitString "/" path));
      baseOf = path: lib.last (lib.splitString "/" path);

      sections = lib.unique (map (e: dirOf e.action) named);

      namedSettings = lib.listToAttrs (map
        (sec: lib.nameValuePair sec (lib.listToAttrs (map
          (e: lib.nameValuePair (baseOf e.action)
            (if e.unbind then [ ] else [ (renderChord "gnome" e) ]))
          (lib.filter (e: dirOf e.action == sec) named))))
        sections);

      customSettings = lib.listToAttrs (map
        (e: lib.nameValuePair e.action {
          binding = renderChord "gnome" e;
          command = e.command;
          name = e.label;
        })
        custom);

      mediaKeys = "org/gnome/settings-daemon/plugins/media-keys";

      customList =
        lib.optionalAttrs (custom != [ ]) {
          ${mediaKeys} = (namedSettings.${mediaKeys} or { }) // {
            custom-keybindings = map (e: "/${e.action}/") custom;
          };
        };
    in
    namedSettings // customSettings // customList;

  # --- shell emitter ---------------------------------------------------------

  # `word` entries on the shell target become the alias set. The description
  # rides along to the cheatsheets and is not part of what the shell sees.
  toShellAliases = entries:
    lib.listToAttrs (map
      (e: lib.nameValuePair e.word e.action)
      (forTarget "fish" entries));

  # --- Hyprland emitter ------------------------------------------------------

  # A bind line is `<variant> = <mods>, <key>, <dispatcher and arguments>`.
  # `$mainMod` is emitted rather than expanded to SUPER, so the generated file
  # still reads like Hyprland configuration.
  #
  # `note` becomes a comment above the line. It is what keeps reasoning at the
  # point of use: the file read while debugging Hyprland is the generated one,
  # so an explanation that lived only in Nix would stop shipping.
  hyprlandLine = e:
    let
      comment =
        if e.note == null then ""
        else lib.concatMapStrings
          (l: if l == "" then "#\n" else "# ${l}\n")
          (lib.splitString "\n" (lib.removeSuffix "\n" e.note));
    in
    (if e.note == null then "" else "\n")
    + comment
    + "${e.variant} = ${renderChord "hyprland" e}, ${e.action}";

  toHyprland = entries:
    lib.concatMapStringsSep "\n" hyprlandLine (forTarget "hyprland" entries);

  # --- tmux emitters ---------------------------------------------------------

  # `;` is tmux's command separator and has to arrive escaped. `\;` is right
  # for a bind line; in the menu's key column only the single-quoted `'\;'`
  # form survives. Bare `;`, `\;`, `';'`, `";"` and `"\;"` all truncate the
  # display-menu command at that argument, silently dropping every entry after
  # it. Measured on tmux 3.6a.
  tmuxEscKey = key: if key == ";" then "\\;" else key;

  tmuxBindLine = e: "bind ${tmuxEscKey e.key} ${e.action}";

  # Keys are padded so the descriptions line up in the menu.
  tmuxPadKey = key:
    let n = 5 - builtins.stringLength key;
    in key + lib.concatStrings (lib.genList (_: " ") (if n > 0 then n else 1));

  # display-menu takes (name, key, command) triples, and renders a lone empty
  # name as a separator line. The command goes in a `{ }` block so tmux keeps
  # it verbatim: several of these carry `#{pane_current_path}`, which a
  # double-quoted argument would expand once at config-parse time and freeze to
  # whatever pane was current then.
  tmuxMenuItem = e:
    "'${tmuxPadKey e.key}${e.desc}' '${tmuxEscKey e.key}' { ${e.action} }";

  toTmuxBinds = entries:
    lib.concatMapStringsSep "\n" tmuxBindLine (forTarget "tmux" entries);

  # Replaces tmux's raw `list-keys` on `?` with a navigable menu of the
  # registry: arrows move, Enter fires, Escape closes, and each entry's
  # accelerator is the key it is bound to. `group` splits the menu, with a
  # separator drawn between the groups.
  toTmuxMenu = entries:
    let
      bound = lib.filter (e: e.menu) (forTarget "tmux" entries);
      inGroup = g: lib.filter (e: e.group == g) bound;
    in
    "bind ? display-menu -T ' custom bindings ' -x C -y C \\\n  "
    + lib.concatStringsSep " \\\n  "
        ((map tmuxMenuItem (inGroup "tools"))
         ++ [ "''" ]
         ++ (map tmuxMenuItem (inGroup "tmux")));

  # --- validation -----------------------------------------------------------

  kinds = [ "chord" "prefixed" "mapped" "word" "sequence" ];

  requiredFields = {
    chord = [ "key" ];  # relaxed for an unbinding, which names no key

    prefixed = [ "key" ];
    mapped = [ "lhs" ];
    word = [ "word" ];
    sequence = [ "seq" ];
  };

  # An unbinding carries no description because it has nothing to describe:
  # it exists to hold a target's default key open.
  needsDesc = entry: !entry.unbind;

  checkEntry = entry:
    let
      label = entryLabel entry;
      errors =
        lib.optional (!lib.elem entry.kind kinds)
          "${label}: unknown kind '${entry.kind}'"
        ++ lib.optional (entry.app == null)
          "${label}: no app"
        ++ lib.optional (needsDesc entry && entry.desc == null)
          "${label}: no desc"
        ++ lib.optionals (!entry.unbind) (map
          (f: "${label}: kind '${entry.kind}' needs '${f}'")
          (lib.filter (f: entry.${f} == null) (requiredFields.${entry.kind} or [ ])))
        ++ lib.optional (entry.kind == "chord" && entry.key != null && !isKnownKey entry.key)
          "${label}: '${entry.key}' is not a known keysym"
        ++ lib.optional (entry.target != null && entry.action == null && !entry.unbind)
          "${label}: targets '${entry.target}' but has no action";
    in
    errors;

  # tmux parses an unescaped `;` as a command separator, reads a leading `-` in
  # a menu name as a flag and as its unselectable marker, and lets an
  # apostrophe close the single-quoted menu name early, swallowing every entry
  # after it. All three fail silently, so they are caught here instead. The
  # rules apply to the tmux target only: a description with an apostrophe is
  # fine everywhere else.
  targetRules = {
    tmux = entry:
      lib.optional (entry.menu && entry.key != null && lib.hasPrefix "-" entry.key)
        ("${entryLabel entry}: a menu row's name begins with its key, and tmux "
         + "renders a name beginning with '-' as dim and unselectable. Set "
         + "menu = false for this binding.")
      ++ lib.optional (entry.desc != null && lib.hasPrefix "-" entry.desc)
        "${entryLabel entry}: a tmux description must not start with '-'"
      ++ lib.optional (entry.desc != null && lib.hasInfix "'" entry.desc)
        "${entryLabel entry}: a tmux description must not contain an apostrophe";
  };

  checkTargetRules = entry:
    let rule = if entry.target == null then null else targetRules.${entry.target} or null; in
    if rule == null then [ ] else rule entry;

  # A binding collides with another only within its own target: `Super+W` in
  # Hyprland and `W` after the tmux prefix are different keys.
  duplicateKey = entry:
    if entry.unbind then null
    else if entry.kind == "chord"
    then "${entry.target}:${lib.concatStringsSep "+" (normaliseMods entry.mods)}+${entry.key}"
    else if entry.kind == "prefixed" then "${entry.target}:prefix ${entry.key}"
    else if entry.kind == "mapped" then "${entry.target}:${lib.concatStringsSep "," entry.mode} ${entry.lhs}"
    else if entry.kind == "word" then "${entry.target}:${entry.word}"
    else null;

  checkDuplicates = entries:
    let
      bound = lib.filter (e: e.target != null && duplicateKey e != null) entries;
      groups = lib.groupBy duplicateKey bound;
      clashes = lib.filterAttrs (_: es: lib.length es > 1) groups;
    in
    lib.mapAttrsToList
      (k: es: "duplicate binding ${k}: "
        + lib.concatMapStringsSep ", "
            (e: "${entryLabel e} (${if e.desc == null then "no desc" else e.desc})") es)
      clashes;

  validate = entries:
    let
      errors =
        lib.concatMap (e: checkEntry e ++ checkTargetRules e) entries
        ++ checkDuplicates entries;
    in
    if errors == [ ]
    then entries
    else throw "hotkeys registry:\n  ${lib.concatStringsSep "\n  " errors}";

in
{
  inherit modifierOrder keysyms displayNames vocab kinds;
  inherit normaliseMods normaliseModsIn isKnownKey isMouseKey entryLabel;
  inherit renderChord displayKey;
  inherit forTarget forScope withoutTarget byApp apps documented groupsOf;
  inherit toKeyb keybSlug toMyhotkeys toTmuxBinds toTmuxMenu toHyprland toShellAliases toGnome toGhostty;
  inherit validate duplicateKey;
}
