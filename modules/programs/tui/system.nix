{ inputs, ... } : {
  flake.modules.nixos.tui-system = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      #SYSTEM
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
