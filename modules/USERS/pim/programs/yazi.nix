{
...
}:
{
  flake.modules.homeManager.pim-yazi = {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

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
