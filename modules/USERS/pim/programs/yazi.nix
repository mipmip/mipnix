{
...
}:
{
  flake.modules.homeManager.pim-yazi = {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "y"; # adopt the modern default (was "yy" pre-26.05)

      # NOTE: office-document preview (yaziPlugins.office) was dropped — the
      # nixpkgs plugin snapshot calls `ya.preview_widgets`, an API not present
      # in the pinned Yazi 26.5.6, so peek crashes. Re-add once versions align.

      settings = {
        mgr = {
          # parent / current / preview column widths.
          # Heavily bias toward the preview pane so it's effectively "zoomed".
          ratio = [ 1 2 5 ];
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          # Inspect the hovered file in a popup (EXIF for images,
          # scrollable content for text) — the closest thing to zooming in.
          {
            on = [ "Z" ];
            run = "spot";
            desc = "Spot the hovered file in a popup";
          }
          # Scroll the preview pane itself.
          {
            on = [ "J" ];
            run = "seek 5";
            desc = "Scroll preview down";
          }
          {
            on = [ "K" ];
            run = "seek -5";
            desc = "Scroll preview up";
          }
        ];
      };
    };
  };
}
