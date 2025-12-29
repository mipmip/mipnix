{

  programs.vim = {
    enable = false;

    extraConfig = ''

        if has('python2')
        endif
        if has('python3')
        endif

        for f in split(glob('~/.vim/base*.vim'), '\n')
          exe 'source' f
        endfor

        for f in split(glob('~/.vim/cli*.vim'), '\n')
          exe 'source' f
        endfor

        for f in split(glob('~/.vim/last*.vim'), '\n')
          exe 'source' f
        endfor

    '';
  };

  home.file = {
    ".vim" = {
      source = ./vim;
      recursive = true;
    };
  };
}
