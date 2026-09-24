{ lib, ... }:
let
  # The neovim keymaps already hold a key, a mode and a description in one
  # place, which is the property this registry exists to create. So they are
  # projected rather than re-authored: keymaps.nix stays the source, and
  # editing a keymap there is still a single edit.
  #
  # The import is of a plain attribute set literal, so it evaluates without a
  # package set and without nixvim in scope. If that file ever becomes a
  # function of lib or pkgs, this breaks loudly at eval time rather than
  # quietly producing nothing.
  keymaps = (import ../../packages/mipvim/config/keymaps.nix).keymaps;

  # A keymap with no description has nothing to show, so it is dropped rather
  # than listed blank.
  described = lib.filter (k: (k.options.desc or null) != null) keymaps;
in
{
  flake.hotkeys = map
    (k: {
      kind = "mapped";
      app = "Neovim";
      target = "nvim";
      scopes = [ "terminal" ];
      lhs = k.key;
      mode = if lib.isList k.mode then k.mode else [ k.mode ];
      desc = k.options.desc;
      action = k.action;
    })
    described;
}
