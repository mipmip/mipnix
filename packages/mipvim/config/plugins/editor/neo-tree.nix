{ helpers, ... }:
{
  plugins.neo-tree = {
    enable = true;
    sources = [
      "filesystem"
      "buffers"
      "git_status"
      "document_symbols"
    ];
    addBlankLineAtTop = false;

    window = {
      mappings = {
        "Y" = helpers.mkRaw ''
          function(state)
             -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
             -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
             local node = state.tree:get_node()
             local filepath = node:get_id()
             local filename = node.name
             local modify = vim.fn.fnamemodify

             local results = {
               filepath,
               modify(filepath, ':.'),
               modify(filepath, ':~'),
               filename,
               modify(filename, ':r'),
               modify(filename, ':e'),
             }

             -- absolute path to clipboard
             local i = vim.fn.inputlist({
               'Choose to copy to clipboard:',
               '1. Absolute path: ' .. results[1],
               '2. Path relative to CWD: ' .. results[2],
               '3. Filename: ' .. results[4],
             })

             if i > 0 then
               local result = results[i]
               if not result then return print('Invalid choice: ' .. i) end
               os.execute('echo ' .. result .. '| wl-copy')
               vim.notify('Copied: ' .. result)
             end
           end
        '';

      };
    };

    filesystem = {
      bindToCwd = false;
      followCurrentFile = {
        enabled = true;
      };
    };

    defaultComponentConfigs = {
      indent = {
        withExpanders = true;
        expanderCollapsed = "󰅂";
        expanderExpanded = "󰅀";
        expanderHighlight = "NeoTreeExpander";
      };

      gitStatus = {
        symbols = {
          added = " ";
          conflict = "󰩌 ";
          deleted = "󱂥";
          ignored = " ";
          modified = " ";
          renamed = "󰑕";
          staged = "󰩍";
          unstaged = "";
          untracked = " ";
        };
      };
    };
  };

  keymaps = [
    {
      mode = [ "n" ];
      key = "<leader>e";
      action = "<cmd>Neotree toggle<cr>";
      options = {
        desc = "Open/Close Neotree";
      };
    }
    {
      mode = [ "n" ];
      key = ",,";
      action = "<cmd>Neotree filesystem reveal left<cr>";
      options = {
        desc = "Open filemanager with location of current file";
      };
    }
  ];
}

#vim.keymap.set('n', '<leader>bf', ':Neotree buffers reveal float<CR>', {})
