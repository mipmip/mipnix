{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-mimosa";
      src = pkgs.fetchFromGitHub {
        owner = "mipmip";
        repo = "vim-mimosa";
        rev = "d6f3af58bc93d255091267aeaee6dddb40496d08";
        hash = "";
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
    '';

}
