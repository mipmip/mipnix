{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      #nextcloud-client
      #seafile-client
      #syncthing
    ];
  };
}
