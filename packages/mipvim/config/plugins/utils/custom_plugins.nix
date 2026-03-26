{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins.mkdx
    pkgs.vimPlugins.vim-better-whitespace
    pkgs.vimPlugins.vim-eunuch
    pkgs.vimPlugins.claudecode-nvim


    #    pkgs.vimPlugins.markdown-nvim
    (pkgs.vimUtils.buildVimPlugin {
      name = "toggle-checkbox";
      src = pkgs.fetchFromGitHub {
        owner = "opdavies";
        repo = "toggle-checkbox.nvim";
        rev = "58f958a2dcfb974963d4bb772ad8c3d8a1c62774";
        hash = "sha256-4YSEagQnLK5MBl2z53e6sOBlCDm220GYVlc6A+HNywg=";
      };
    })

    (pkgs.vimUtils.buildVimPlugin {
      name = "path-yank";
      src = pkgs.fetchFromGitHub {
        owner = "ywpkwon";
        repo = "yank-path.nvim";
        rev = "e660248de1e4c91a760f510fc165c172a19cc1d5";
        hash = "sha256-z6USTspCiWU6UEP9TyACvzlb4MGEadBKUfxN2vJyeV0=";
      };
    })

  ];

    extraConfigLua =
      ''
        require('claudecode').setup({
          -- opts = {},
          keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
              "<leader>as",
              "<cmd>ClaudeCodeTreeAdd<cr>",
              desc = "Add file",
              ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
          },
        })

      '';


}
