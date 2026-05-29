{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-mimosa";
      src = pkgs.fetchFromGitHub {
        owner = "mipmip";
        repo = "vim-mimosa";
        rev = "d6f3af58bc93d255091267aeaee6dddb40496d08";
        hash = "sha256-nWrMRHPHVliWneJiCLp0Rn8ifh4M1481bmk4CK0Pk7g=";
      };
    })

    (pkgs.vimUtils.buildVimPlugin {
      name = "scimark";
      src = pkgs.fetchFromGitHub {
        owner = "mipmip";
        repo = "vim-scimark";
        rev = "e6947e1f5dee201a01a29d147363b6ad0b020dba";
        hash = "sha256-55Mv0iOi14g+bM7Mz2GnHoFG4J8y2ijHpUmtL+jpBPA=";
      };
    })

  ];
  extraConfigLua =
    ''
      vim.keymap.set("n", "<leader>mo", ":Mimosa<CR>")
      vim.keymap.set("n", "<leader>mn", ":MimosaNew<CR>")
      vim.keymap.set("n", "<leader>ms", ":MimosaNew svg<CR>")

      -- open-mip: open current file in mip
      vim.keymap.set("n", "<leader>mi", ":MIP<CR>")
      vim.api.nvim_create_user_command("MIP", function()
        local file = vim.fn.expand("%")
        if vim.fn.filereadable(file) == 1 then
          local cmd = (vim.g.mip_exec_path or "mip") .. " " .. vim.fn.shellescape(file)
          vim.fn.jobstart(cmd, { detach = true })
        end
      end, {})
    '';

}
