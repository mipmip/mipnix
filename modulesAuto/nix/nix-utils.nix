{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.nixUtils.enable {
    environment.systemPackages = with pkgs; [

      nix-index
      patchelf
      nix-tree

      nix-search-tv
      nix-output-monitor

    ];
  };
}


