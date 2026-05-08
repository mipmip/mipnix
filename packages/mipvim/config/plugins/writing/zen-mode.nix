{
  plugins.zen-mode = {
    enable = true;
    settings = {
      # lifted from https://nix-community.github.io/nixvim/plugins/zen-mode/settings/index.html
      plugins = {
        #bufferline.enabled = true; # doesn't work for some reason
        gitsigns.enabled = false;
        tmux.enabled = false;
        options = {
          enabled = true;
          ruler = false;
          showcmd = false;
        };
        #twilight.enabled = true;
      };
      window = {
        backdrop = 1;
        height = 0.9;
        options = {
          number = false;
          signcolumn = "no";
          cursorline = false;
          cursorcolumn = false;
          foldcolumn = "0";
        };
        width = 80;
      };
      on_open = ''
                function(win)
                   local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
                   local result = handle:read("*a")
                   handle:close()
                   if result:find("prefer%-dark") then
                     vim.o.background = 'dark'
                   else
                     vim.cmd.colorscheme('whitewriter')
                   end
                   vim.opt.relativenumber = false
                   vim.opt.number = false
                end
      '';
      on_close = ''
                function(win)
                   vim.cmd.colorscheme('gruvbox')
                   vim.opt.relativenumber = true
                   vim.opt.number = true
        --           require('lualine').hide({
        --               unhide = true,
        --           })
                end
      '';
    };

    # twilight.enable = true; ## why is this here? zen mode has no twilight
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>Z";
      action = "<Cmd>ZenMode<CR>";
      options = {
        silent = true;
        desc = "Zen-mode toggle";
      };
    }
  ];

}
