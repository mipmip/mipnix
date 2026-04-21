{
  flake.modules.nixos.user-pim = { config, pkgs, ... }: {

    programs.fish.enable = true;
    users.users.pim = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk" "input"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh"
      ];

    };
  };
}
