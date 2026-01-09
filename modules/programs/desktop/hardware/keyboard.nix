{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-keyboard = { config, pkgs, ... }: {
    services.xserver.displayManager.sessionCommands =
      let
        myCustomLayout = pkgs.writeText "xkb-layout" ''
          clear lock
          ! disable capslock
          ! remove Lock = Caps_Lock
        '';
      in
        "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";
  };
}
