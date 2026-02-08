{ inputs, ... } : {

  flake.modules.nixos.granny = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      vim
      bitwarden-desktop
      tmux
      git

      wget

      firefox

      pkgs.unstable.newelle
      pkgs.unstable.signal-desktop
      flare-signal

      pkgs.nebula

      rustdesk

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

      seafile-client

      fastmail-desktop


    ];


  };
}






