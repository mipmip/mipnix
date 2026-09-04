{
...
}:
let
  hostname = "doornappel";
in
{
  flake.nebulaNodes.doornappel = "192.168.100.15";

  flake.modules.nixos.doornappel = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
