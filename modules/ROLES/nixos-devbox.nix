{
  inputs,
  ...
}:
{
  flake.modules.nixos.role-devbox = {
    imports = with inputs.self.modules.nixos; [

      # Development tools - Languages
      dev-lang-c
      dev-lang-crystal
      dev-lang-go
      dev-lang-ruby
      dev-lang-rust
      dev-lang-nodejs

      # Development tools - Tools
      dev-tools-docker
      dev-tools-android
      dev-tools-build

      # Development tools - VCS
      dev-vcs-github
      dev-vcs-git-utils

      # Development tools - Infrastructure
      dev-infra-dataformat
      dev-infra-iac

      nix-utils
      nix-nixpkgs-dev

      # Tex/Documentation
      tex-main
      tex-linny

      # Cobol
      #cobol-main

      # TUI tools
      tui-disk
      tui-file-utils
      tui-hardware
      tui-help
      tui-multimedia
      tui-net
      tui-search
      tui-security
      tui-shell
      tui-system
      tui-tmux

      vibecoding-main
      vibecoding-utils


      db-psql


    ];
  };
}

