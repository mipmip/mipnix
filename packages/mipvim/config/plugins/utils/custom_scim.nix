{ pkgs, ... }:
{
  extraPlugins = [

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
}
