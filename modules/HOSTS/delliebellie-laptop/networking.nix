{
...
}:
let
  hostname = "delliebellie";
in
{
  flake.nebulaNodes.delliebellie = "192.168.100.3";

  flake.modules.nixos.delliebellie = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
