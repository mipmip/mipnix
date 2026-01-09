{ inputs, ... } : {
  flake.modules.nixos.desktop-system-security = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      bitwarden-desktop
      lynis
    ];
  };
}
