{ inputs, self, ... }:

let
  hostname = "lego2";
in

  {

  flake.homeConfigurations = {

    "pim@lego2" = self.lib.makeHomeConf {
      inherit hostname;
      #secondbrain = true;
      #awscontrol = true;
      #desktop = true;
      imports = with inputs.self.modules.homeManager; [
        pim-with-desktop
        pim-with-secondbrain
      ];

    };
  };

  flake.nixosConfigurations = {

    lego2 = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  #flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" hostname;

  flake.modules.nixos.lego2 = { config, pkgs, ... } : {
    system.stateVersion = "25.05";

    imports = with inputs.self.modules.nixos; [

      system-default
      system-locale

      inputs.nixos-hardware.nixosModules.framework-13-7040-amd

      hm-nixos
      hardware-keychron
      framework-fingerprint
      framework-misc
     networking-wifi

      desktop-myhotkeys

      nix-cli
      nix-age
      nix-utils
      nix-nixpkgs-dev

      users-core

      system-luks
      system-trusted-agenix

      services-samba

      # Development tools - Languages
      dev-lang-c
      dev-lang-crystal
      dev-lang-go
      dev-lang-python
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

      # Desktop foundation - System
      desktop-system-x11
      desktop-system-security
      desktop-system-services

      # Desktop foundation - Hardware
      desktop-hw-audio
      desktop-hw-video
      desktop-hw-keyboard

      # Desktop foundation - Utils
      desktop-utils-fonts

      # Desktop environments
      desktop-de-gnome
      desktop-de-hyprland

      # Desktop applications
      desktop-apps-browsers
      desktop-apps-mail
      desktop-apps-communication
      desktop-apps-news
      desktop-apps-ai
      desktop-apps-dtp
      desktop-apps-markdown
      desktop-apps-dev

      # Desktop tools & hardware
      desktop-virt-virtualization
      desktop-virt-appimage
      desktop-hw-bambu-labs
      desktop-hw-printers
      desktop-utils-filesync

      # Editors
      editors-vim

      # Tex/Documentation
      tex-main
      tex-linny

      # Cobol
      cobol-main

      # TUI tools
      tui-disk
      tui-file-utils
      tui-hardware
      tui-help
      tui-multimedia
      tui-neovim
      tui-net
      tui-search
      tui-security
      tui-shell
      tui-system
      tui-tmux

      # Home Manager
      hm-integration

      vibecoding-main
      vibecoding-utils

      virtualisation-waydroid

      db-psql

      networking-nebula

    ];

    # All modulesAuto options removed - now using imports above
    # Migration complete! All modulesAuto modules have been migrated to dendritic pattern.
  };

}
