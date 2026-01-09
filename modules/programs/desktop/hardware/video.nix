{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-video = { config, pkgs, ... }: {
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
