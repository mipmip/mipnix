{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.slack

      #msmtp
      #    unstable.whatsapp-for-linux
      pkgs.unstable.signal-desktop
      pkgs.unstable.flare-signal

      #tdesktop
      v4l-utils

      zoom-us
      rustdesk
      # teams

      #    unstable.srain #IRC
      pkgs.unstable.tuba # Mastodon

      discord
      vesktop

      pkgs.unstable.himalaya
    ];
  };
}
