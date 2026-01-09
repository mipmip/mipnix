{ inputs, ... } : {
  flake.modules.nixos.desktop-hw-audio = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      spotify
      sox
    ];
  };
}
