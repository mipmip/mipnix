{ inputs, ... } : {

  flake.modules.nixos.granny = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [

      inputs.rme.packages."${pkgs.stdenv.hostPlatform.system}".default

      vim
      tmux
      git

      wget

      moving.firefox
      flare-signal

      moving.fastmail-desktop
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
