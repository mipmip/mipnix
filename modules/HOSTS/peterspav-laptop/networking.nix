{
...
}:
let
  hostname = "peterspav";
in
{
  flake.modules.nixos.peterspav = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
