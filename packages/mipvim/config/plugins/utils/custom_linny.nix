{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "linny";
      src = pkgs.fetchFromGitHub {
        owner = "linden-project";
        repo = "linny.vim";
        rev = "e5e4689c29f303b8a5a45b16b71e36647d037363";
        hash = "sha256-iMOrAcGRHJBIQCg5XDMkFG6n6gjuLkguCmUKBEDjQLc=";
      };
      nvimSkipModule = [
        "linny"
        "linny.menu"
        "linny.menu.init"
      ];
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
