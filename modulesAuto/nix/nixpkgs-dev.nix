{ config, lib, pkgs, ... }:{

  config = lib.mkIf config.nixos.nixpkgsDev.enable {
    environment.systemPackages = with pkgs; [
      nixpkgs-review
      nix-output-monitor
      glow
      delta
    ];
  };
}



