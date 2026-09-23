{
...
}:
let
  hostname = "peterspav";
in
{
  flake.nebulaNodes.peterspav = "192.168.100.16";

  flake.modules.nixos.peterspav = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
