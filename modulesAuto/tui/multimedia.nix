{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # GRAPHIC
    imagemagick
    imgp
    oxipng
    pngquant

    ffmpegthumbnailer # video thumbnails
    poppler-utils # pdf thumbnails
    catimg
  ];
}

