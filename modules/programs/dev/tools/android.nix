{ inputs, ... } : {
  flake.modules.nixos.dev-tools-android = { config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
