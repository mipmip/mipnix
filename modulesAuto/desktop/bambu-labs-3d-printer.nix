{ config, lib, pkgs, unstable, ... }:{

  config = lib.mkIf config.nixos.bambulabs.enable {
    nixpkgs.config.permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];

    environment.systemPackages = with pkgs; [
      bambu-studio
    ];
  };
}


