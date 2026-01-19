{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins.mkdx
    pkgs.vimPlugins.vim-better-whitespace
    pkgs.vimPlugins.vim-eunuch

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

  ];

}
