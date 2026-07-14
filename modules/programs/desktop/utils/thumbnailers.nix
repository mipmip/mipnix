{ inputs, ... } : {
  flake.modules.nixos.desktop-utils-thumbnailers = { config, pkgs, ... }: {
    # Thumbnailers used by Nautilus (and other GNOME apps) to render
    # preview icons. gdk-pixbuf provides gdk-pixbuf-thumbnailer, the
    # thumbnailer for raster images (PNG/JPEG/...) — without it images
    # get no previews. ffmpegthumbnailer covers video/audio.
    environment.systemPackages = with pkgs; [
      gdk-pixbuf
      ffmpegthumbnailer
    ];
  };
}
