{ lib, ... }:
let
  hotkeys = import ../../lib/hotkeys.nix { inherit lib; };

  entry = {
    options = {

      kind = lib.mkOption {
        type = lib.types.enum hotkeys.kinds;
        description = ''
          What shape this entry is. `chord` is an absolute modifier
          combination, `prefixed` a key pressed after a leading key, `mapped`
          an editor mode with a left-hand side, `word` something typed rather
          than pressed, and `sequence` an in-application run of keys that this
          configuration does not bind.
        '';
      };

      app = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Cheatsheet section this entry belongs to.";
      };

      target = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [
          "hyprland" "tmux" "fish" "ghostty" "gnome" "nvim"
        ]);
        default = null;
        description = ''
          Who binds this key. `null` means nobody here does, so the entry is
          documentation and reaches no configuration file.
        '';
      };

      desc = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "What the binding does, as it reads in a cheatsheet.";
      };

      scopes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Which viewers select this entry. The empty list means every one of
          them.
        '';
      };

      note = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Reasoning worth keeping at the point of use. Generators that can emit
          a comment put it above the generated line.
        '';
      };

      mods = lib.mkOption {
        type = lib.types.listOf (lib.types.enum hotkeys.modifierOrder);
        default = [ ];
        description = "Canonical modifiers of a chord, in any order.";
      };

      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "X11 keysym for a chord, or the key of a prefixed binding.";
      };

      prefixLabel = lib.mkOption {
        type = lib.types.str;
        default = "prefix";
        description = ''
          How the leading key of a prefixed binding is named in a cheatsheet.
          It is a label rather than a key combination because the running tmux
          prefix is switched at will by the tmxa and tmxb aliases.
        '';
      };

      mode = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Editor modes a mapped entry applies in.";
      };

      lhs = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Left-hand side of a mapped entry, in the editor's own notation.";
      };

      word = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The text typed, for an alias or an abbreviation.";
      };

      seq = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "An in-application key run, written as it is pressed.";
      };

      action = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          What the binding runs, in the target's own syntax. It is carried
          verbatim and never rewritten, because a Hyprland dispatcher, a tmux
          command and a shell command share no common form.
        '';
      };

      variant = lib.mkOption {
        type = lib.types.enum [ "bind" "bindel" "bindm" "bindl" ];
        default = "bind";
        description = "Hyprland bind flavour.";
      };

      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          gnome only: the command a custom keybinding runs. Its presence is
          what makes an entry a custom keybinding rather than a binding of a
          named gnome action.
        '';
      };

      label = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "gnome only: the name a custom keybinding is stored under.";
      };

      group = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Sub-grouping within a target, used by the tmux menu.";
      };

      menu = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether this entry belongs in the menu its target generates. Set it
          false for a binding that only means something in a context the menu
          cannot represent, such as a key that acts only while a popup is open:
          a flat list invites the reader to fire it, and firing it does nothing.

          Independent of `document`. An entry kept out of the menu still reaches
          the cheatsheets unless it is undocumented as well.
        '';
      };

      document = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether this entry appears in the cheatsheets. Set it false for one
          member of a family that is documented by another, such as the nine
          further workspace keys behind "Move to workspace 1 (idem for 2-9)".
        '';
      };

      unbind = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Hold a target's default key open rather than bind it. An unbinding
          needs no description and appears in no cheatsheet.
        '';
      };
    };
  };
in
{
  # Single source of truth for every keybinding, shell word and cheatsheet
  # reminder, contributed from any module the way flake.nebulaNodes is
  # contributed per host. Emitters read it through flake.lib.hotkeys; nothing
  # keeps a second list.
  #
  # Reads literal strings only, so it evaluates without a package set and
  # without recursing through inputs.self.
  options.flake.hotkeys = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule entry);
    default = [ ];
    apply = hotkeys.validate;
    description = "Registry of keybindings, shell words and cheatsheet entries.";
  };
}
