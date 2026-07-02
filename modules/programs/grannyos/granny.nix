{ inputs, ... } : {

  flake.modules.nixos.granny = { pkgs, ... }:
  let
    # The fastmail Electron app announces its Wayland app-id as
    # `com.fastmail.Fastmail` (its productName), but the upstream package ships
    # `fastmail.desktop`. GNOME's dock matches a running window to a desktop
    # file by app-id → same-basename desktop file, so it looks for
    # `com.fastmail.Fastmail.desktop`, doesn't find it, and falls back to the
    # window's (empty) icon → a transparent dock icon. (The app grid is fine
    # because it reads fastmail.desktop directly.) Fix: also install a copy of
    # the desktop file named after the app-id so the dock can match it.
    fastmail-desktop = pkgs.symlinkJoin {
      name = "fastmail-desktop-appid-fix";
      paths = [ pkgs.moving.fastmail-desktop ];
      postBuild = ''
        cp --remove-destination \
          "${pkgs.moving.fastmail-desktop}/share/applications/fastmail.desktop" \
          "$out/share/applications/com.fastmail.Fastmail.desktop"
      '';
    };
  in {

    environment.systemPackages = with pkgs; [

      inputs.rme.packages."${pkgs.stdenv.hostPlatform.system}".default

      vim
      tmux
      git

      wget

      moving.firefox
      flare-signal

      fastmail-desktop
      moving.bitwarden-desktop
      #moving.newelle
      unstable.signal-desktop
      moving.rustdesk

      nebula

      gcc
      pkg-config
      gnumake

      gimp
      inkscape

      libreoffice
      hunspellDicts.nl_nl

      ghostty

      #gnome-tweaks
      #gpaste
    ];
  };
}
