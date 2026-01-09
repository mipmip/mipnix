{ inputs, ... } : {
  flake.modules.nixos.desktop-utils-filesync = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      #nextcloud-client
      #seafile-client
      #syncthing
    ];
  };
}
