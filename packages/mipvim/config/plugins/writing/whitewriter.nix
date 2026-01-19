{ pkgs, ... }:
{
  extraPlugins = [

    (pkgs.vimUtils.buildVimPlugin {
      name = "whitewriter";
      src = pkgs.fetchFromGitHub {
        owner = "mipmip";
        repo = "vim-whitewriter";
        rev = "main";
        hash = "sha256-/BIPCbhlousdFpv7d4U1dUclyzSpK7HcZ2gOqlT93xo=";
      };
    })

  ];
}
