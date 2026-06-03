{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-ai = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

    ];
  };
}
