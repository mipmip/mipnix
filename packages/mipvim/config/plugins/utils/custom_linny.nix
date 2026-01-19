{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "linny";
      src = pkgs.fetchFromGitHub {
        owner = "linden-project";
        repo = "linny.vim";
        rev = "cef962e96ccff85e25aa911f2e20fa5daf08b3fd";
        hash = "sha256-jIXNclctwpDKfGP4dh5YvrXE9sXN8SWfcS75uspfAYM=";
      };
    })

  ];

  extraConfigLua =
    # lua
    ''
      local f=io.open( os.getenv( "HOME" ) .. "/.i-am-second-brain","r")

      if f~=nil then
        io.close(f)

        vim.g.linny_open_notebook_path = vim.env.HOME .. '/secondbrain'

        vim.g.linny_menu_display_docs_count = 1
        vim.g.linny_menu_display_taxo_count = 1
        vim.g.linnycfg_setup_autocommands = 1

        vim.cmd [[
          let g:linny_wikitags_register = {}
        ]]
        vim.fn['linny#Init']()
      end
    '';
}
