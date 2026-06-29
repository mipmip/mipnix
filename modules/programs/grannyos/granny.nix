{ inputs, ... } : {

  flake.modules.nixos.granny = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      vim
      tmux
      git

      wget

      firefox
      #thunderbird
      flare-signal
      #seafile-client
      fastmail-desktop

      moving.bitwarden-desktop
      moving.newelle
      moving.signal-desktop

      nebula

      moving.rustdesk

      gcc
      pkg-config
      gnumake

      gimp
      inkscape

      libreoffice
      hunspellDicts.nl_nl

      ghostty

      gnome-tweaks
      gpaste



    ];


  };
}






