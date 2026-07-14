{
...
}:
{
  flake.modules.homeManager.pim-yazi = { pkgs, ... }: {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

      # Preview office documents (docx/xlsx/pptx/odt/...).
      plugins.office = pkgs.yaziPlugins.office;

      # The office plugin shells out to these; keep them on yazi's PATH
      # only (rather than installing globally).
      extraPackages = with pkgs; [
        libreoffice
        poppler-utils # provides pdftoppm
      ];

      settings = {
        mgr = {
          # parent / current / preview column widths.
          # Heavily bias toward the preview pane so it's effectively "zoomed".
          ratio = [ 1 2 5 ];
        };

        plugin = {
          prepend_preloaders = [
            { mime = "application/openxmlformats-officedocument.*"; run = "office"; }
            { mime = "application/oasis.opendocument.*"; run = "office"; }
            { mime = "application/ms-*"; run = "office"; }
            { mime = "application/msword"; run = "office"; }
            { url = "*.docx"; run = "office"; }
          ];
          prepend_previewers = [
            { mime = "application/openxmlformats-officedocument.*"; run = "office"; }
            { mime = "application/oasis.opendocument.*"; run = "office"; }
            { mime = "application/ms-*"; run = "office"; }
            { mime = "application/msword"; run = "office"; }
            { url = "*.docx"; run = "office"; }
          ];
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
