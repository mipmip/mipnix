{
inputs,
...
}:
{
  # Ghostty keybindings, declared once and rendered into ghostty's own key
  # spelling by the emitter: `Return` becomes `enter`, and the letters are
  # lowercased.
  flake.hotkeys = [
    { kind = "chord"; app = "Ghostty"; target = "ghostty"; scopes = [ "terminal" ];
      mods = [ "ctrl" "shift" ]; key = "C"; action = "copy_to_clipboard";
      desc = "Copy to clipboard"; }
    { kind = "chord"; app = "Ghostty"; target = "ghostty"; scopes = [ "terminal" ];
      mods = [ "ctrl" "shift" ]; key = "V"; action = "paste_from_clipboard";
      desc = "Paste from clipboard"; }
  ];

  flake.modules.homeManager.pim-ghostty = {
    programs.hm-ricing-mode.apps.ghostty = {
      dest_dir = ".config/ghostty";
    };

    programs.ghostty = {
      enable = true;
      settings = {
        # Must be a Nerd Font; the default fallback (Ubuntu Mono) lacks the
        # icon glyphs neovim/neo-tree use (git markers, diagnostics, tree
        # expanders), which then render as tofu boxes.
        font-family = "JetBrainsMono Nerd Font";
        window-padding-x = 3;
        confirm-close-surface = false;
        window-padding-y = 3;
        theme = "dark:Gruvbox Material,light:Gruvbox Material";
        #theme = "dark:Gruvbox Material,light:Gruvbox Material Light";
        #theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
        cursor-invert-fg-bg = true;
        mouse-hide-while-typing = true;
        copy-on-select = "clipboard";
        gtk-tabs-location = "hidden";
        keybind = inputs.self.lib.hotkeys.toGhostty inputs.self.hotkeys;
      };
    };
  };
}
