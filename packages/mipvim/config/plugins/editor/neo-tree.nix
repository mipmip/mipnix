{ lib, ... }:
{
  plugins.neo-tree = {
    enable = true;

    settings = {
      sources = [
        "filesystem"
        "buffers"
        "git_status"
        "document_symbols"
      ];

      add_blank_line_at_top = false;
      enable_git_status = true;
      enable_diagnostics = true;

      filesystem = {
        bind_to_cwd = false;
        use_libuv_file_watcher = true;
        follow_current_file = {
          enabled = true;
        };
      };

      # Auto-reload: the libuv watcher only covers expanded directories and
      # never refreshes git_status. Bridge Neovim autocmds to neo-tree
      # refreshes so external file changes (A) and git-state changes (B)
      # show up without a manual `R`.
      event_handlers = [
        {
          # File written inside nvim → its git state may have changed.
          event = "vim_buffer_changed";
          handler = lib.nixvim.mkRaw ''
            function()
              require("neo-tree.sources.manager").refresh("git_status")
              require("neo-tree.sources.manager").refresh("filesystem")
            end
          '';
        }
        {
          # Regaining focus / returning to nvim → catch external edits,
          # `git checkout`, files moved in a terminal, etc.
          event = "vim_buffer_enter";
          handler = lib.nixvim.mkRaw ''
            function()
              require("neo-tree.sources.manager").refresh("git_status")
            end
          '';
        }
        {
          # libuv detected an on-disk change in a watched directory.
          event = "fs_event";
          handler = lib.nixvim.mkRaw ''
            function()
              require("neo-tree.sources.manager").refresh("git_status")
            end
          '';
        }
      ];

      default_component_configs = {
        indent = {
          with_expanders = true;
          expander_collapsed = "󰅂";
          expander_expanded = "󰅀";
          expander_highlight = "NeoTreeExpander";
        };

        git_status = {
          symbols = {
            added = " ";
            conflict = "󰩌 ";
            deleted = "󱂥";
            ignored = " ";
            modified = " ";
            renamed = "󰑕";
            staged = "󰩍";
            unstaged = "";
            untracked = " ";
          };
        };
      };

      window = {
        mappings = {
          Y = lib.nixvim.mkRaw ''
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
