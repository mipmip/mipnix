{ inputs, ... } : {
  flake.modules.nixos.tui-system = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # SHELL
      gum

      # NET


      #SYSTEM
      lsof
      htop
      util-linux
      sysstat
      iotop
      binutils
      gettext
      psmisc
      file
      neofetch
      fastfetch
    ];
  };
}
