{ inputs, ... } : {
  flake.modules.nixos.dev-tools-android = { config, pkgs, ... }: {

    programs.adb.enable = true;

    users.users.pim.extraGroups = ["adbusers"];

    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
