{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.dev.enable {
    environment.systemPackages = with pkgs; [
      go
      gox
      goreleaser

    ];
  };
}

