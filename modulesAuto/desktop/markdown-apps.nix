{ config, lib, pkgs, inputs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [

      inputs.mip.packages."${ pkgs.stdenv.hostPlatform.system }".default
    ];
  };
}
