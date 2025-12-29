{ config, lib, pkgs, unstable, ... }:{

  config = lib.mkIf config.nixos.dev.enable {
    environment.systemPackages = with pkgs; [
      #language servers
      sqls
      gopls
      unstable.nixd
      marksman
      terraform-ls
      nodePackages.bash-language-server
      lua-language-server

      #unstable.neovim
      unstable.nil
      unstable.tree-sitter

      vscode-langservers-extracted

      # Language Server Dependencies
      #nodePackages.pyright
      nodePackages.tailwindcss

      # Formatters
      nixfmt-classic
      nodePackages.prettier

    ];
  };
}

