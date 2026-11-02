{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-video = { config, lib, pkgs, ... }:
    let
      cfg = config.mipnix.desktop;
    in
    {
      options.mipnix.desktop.obs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install OBS Studio with the plugin set used for screen recording.
          Set to false on a host that never records; OBS and its plugins cost
          around 4 GB of store. The rest of the video tooling stays either way.
        '';
      };

      config.environment.systemPackages = with pkgs; [
        #    openshot-qt
        x264
        ffmpeg
        vlc
        vhs

        #stremio
        remote-touchpad
      ] ++ lib.optional cfg.obs (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          advanced-scene-switcher
          input-overlay
          obs-backgroundremoval
          obs-composite-blur
          obs-retro-effects
        ];
      });
    };
}
