{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-bambu-labs = { config, pkgs, ... }: {
    nixpkgs.config.permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];

    environment.systemPackages = with pkgs; [
      #bambu-studio
    ];
  };
}
