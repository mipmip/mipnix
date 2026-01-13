{ inputs, ... } : {
  flake.modules.nixos.desktop-system-x11 = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      dragon-drop # Drag and drop utility
    ];
  };
}
