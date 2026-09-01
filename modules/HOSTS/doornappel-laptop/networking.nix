{
...
}:
let
  hostname = "doornappel";
in
{
  flake.modules.nixos.doornappel = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
