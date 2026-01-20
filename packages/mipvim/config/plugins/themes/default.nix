{
  colorschemes = {
    gruvbox = {
      enable = true;
    };
    gruvbox-baby = {
      enable = true;
    };
    tokyonight = {
      enable = true;
      setting = {
        day_brightness = 0.3;
        dim_inactive = true;
        hide_inactive_statusline = false;
        light_style = "day";
        lualine_bold = false;
        on_colors = "function(colors) end";
        on_highlights = "function(highlights, colors) end";
        sidebars = [
          "qf"
          "vista_kind"
          "terminal"
          "packer"
        ];
        style = "storm";
        styles = {
          comments = {
            italic = true;
          };
          floats = "dark";
          functions = { };
          keywords = {
            italic = true;
          };
          sidebars = "dark";
          variables = { };
        };
        terminal_colors = true;
        transparent = false;
      };
    };
    catppuccin = {
      enable = true;
      settings = {
        background = {
          light = "macchiato";
          dark = "mocha";
        };
        custom_highlights = ''
          function(highlights)
            return {
            CursorLineNr = { fg = highlights.peach, style = {} },
            NavicText = { fg = highlights.text },
            }
          end
        '';
        flavour = "macchiato"; # "latte", "mocha", "frappe", "macchiato" or raw lua code
        no_bold = false;
        no_italic = false;
        no_underline = false;
        transparent_background = true;
        integrations = {
          cmp = true;
          notify = true;
          gitsigns = true;
          neotree = true;
          which_key = true;
          illuminate = {
            enabled = true;
            lsp = true;
          };
          navic = {
            enabled = true;
            custom_bg = "NONE";
          };
          treesitter = true;
          telescope.enabled = true;
          indent_blankline.enabled = true;
          mini = {
            enabled = true;
            indentscope_color = "rosewater";
          };
          native_lsp = {
            enabled = true;
            inlay_hints = {
              background = true;
            };
            virtual_text = {
              errors = [ "italic" ];
              hints = [ "italic" ];
              information = [ "italic" ];
              warnings = [ "italic" ];
              ok = [ "italic" ];
            };
            underlines = {
              errors = [ "underline" ];
              hints = [ "underline" ];
              information = [ "underline" ];
              warnings = [ "underline" ];
            };
          };
        };
      };
    };
  };
}
