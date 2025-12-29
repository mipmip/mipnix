{ lib, ... }:

{
  options.nixos.full = {
    enable = lib.mkEnableOption "full install";
  };
}

