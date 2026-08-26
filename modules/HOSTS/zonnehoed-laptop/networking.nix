{
...
}:
let
  hostname = "zonnehoed";
in
{
  flake.modules.nixos.zonnehoed = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

  };
}
