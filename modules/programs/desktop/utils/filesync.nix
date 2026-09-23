{ inputs, ... } : {
  # Syncthing is NOT installed from here. The Work pool owns it:
  # modules/services/sync/syncthing-pool.nix enables `services.syncthing` on the
  # hosts that are pool members, which brings the package with it. A commented-out
  # package line here would read as the plan when it is not.
  flake.modules.nixos.desktop-utils-filesync = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      #nextcloud-client
      #seafile-client
    ];
  };
}
