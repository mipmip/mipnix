{
  flake.modules.nixos.user-tim = { config, pkgs, ... }: {

    users.users.tim = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };
  };
}
