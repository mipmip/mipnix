{ lib, pkgs, ... }:

{

  programs.hm-ricing-mode.enable = true;

  imports = [
    ./_hm-modules
  ];

}
