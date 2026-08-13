{
...
}:
let
  hostname = "cichorei";
in
{
  flake.modules.nixos.cichorei = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
