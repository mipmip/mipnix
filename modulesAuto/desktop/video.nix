{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      #    openshot-qt
      x264
      ffmpeg
      vlc
      vhs

      #stremio
      remote-touchpad

      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          advanced-scene-switcher
          input-overlay
          obs-backgroundremoval
          obs-composite-blur
          #obs-pipewire-audio-capture
        ];
      })

    ];
  };
}

