{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      unstable.slack

      #msmtp
      #    unstable.whatsapp-for-linux
      unstable.signal-desktop
      unstable.flare-signal

      #tdesktop
      v4l-utils

      zoom-us
      rustdesk
      # teams

      #    unstable.srain #IRC
      unstable.tuba # Mastodon

      discord
      vesktop

      unstable.himalaya
    ];
  };
}
