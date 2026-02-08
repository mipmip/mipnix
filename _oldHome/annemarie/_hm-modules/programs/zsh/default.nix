{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = false;

    shellAliases = {
      open = "xdg-open";
    };

    oh-my-zsh = {
      enable = true;
      plugins=["git"];
    };

    initExtra = ''
    '';
  };
}
