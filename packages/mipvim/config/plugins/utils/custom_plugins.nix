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

    #    (pkgs.vimUtils.buildVimPlugin {
    #      name = "age";
    #      src = pkgs.fetchFromGitHub {
    #        owner = "abhinandh-s";
    #        repo = "age.nvim";
    #        rev = "ie660248de1e4c91a760f510fc165c172a19cc1d5";
    #        hash = "sha256-z6USTspCiWU6UEP9TyACvzlb4MGEadBKUfxN2vJyeV0=";
    #      };
    #    })


    (pkgs.vimUtils.buildVimPlugin {
      name = "tmux-sendit";
      src = pkgs.fetchFromGitHub {
        owner = "mipmip";
        repo = "tmux-sendit.nvim";
        rev = "834e66f3";
        hash = "sha256-bn3VbvWqchhNVwI/a/oH7EZMRi8hq0JyXtNhPE41nxE=";
      };
    })
  ];

  extraConfigLua = ''
    require('sendit').setup({
      pane_scope = "window",
    })
  '';


}
