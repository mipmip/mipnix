{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-mail = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      #pkgs.unstable.fastmail-desktop
    ];
  };
}
