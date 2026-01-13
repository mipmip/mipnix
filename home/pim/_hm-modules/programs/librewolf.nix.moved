{ config, lib, pkgs, ... }:

let
  cfg = config.desktopConf.librewolf;
in
  {

  options.desktopConf.librewolf = {
    enable = lib.mkEnableOption "Enable librewolf";
  };

  config = lib.mkIf cfg.enable {

    programs.librewolf = {
      enable = true;
      # Enable WebGL, cookies and history
      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0;
      };
    };
  };
}

