{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.obs;
in
  {

  options.desktopConf.obs = {
    enable = lib.mkEnableOption "configure obs";
  };

  config = lib.mkIf cfg.enable {
  };
}
