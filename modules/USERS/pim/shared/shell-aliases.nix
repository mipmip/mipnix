{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shared-shell-aliases = { lib, config, ... }: {

    options.shared.shellAliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = lib.literalExpression ''
        {
          g = "git";
          "..." = "cd ../..";
        }
      '';
      description = ''
        An attribute set that maps aliases (the top level attribute names
        in this option) to command strings or directly to build outputs.
      '';
    };

    config = lib.mkMerge [
      {
        # The alias set comes from the hotkey registry (shell-words.nix), so an
        # alias is declared once and carries a description into the cheatsheets.
        # mkDefault keeps the host-conditional block below winning, as it did
        # when `t` and `smugs` carried mkDefault by hand.
        shared.shellAliases = lib.mapAttrs
          (_: lib.mkDefault)
          (inputs.self.lib.hotkeys.toShellAliases inputs.self.hotkeys);
      }

      (lib.mkIf config.homeWith.secondbrain.enable {

        shared.shellAliases = {
          t = "tmux a || smug start lobby && smug start doen && smug start sudo && smug start nixos && smug start tekst";
          smugs = "smug start doen && smug start sudo && smug start nixos && smug start lobby";
          #nlin = "tmux set -p allow-passthrough on && nvim -c LinnyStart $HOME/secondbrain/wikiContent/doen_werk.md";
          nlin = "nvim -c LinnyStart $HOME/secondbrain/content/doen_werk.md";
          nvim = "nvim";
        };

      })
    ];
  };
}
