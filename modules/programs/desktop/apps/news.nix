{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-news = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      newsflash
    ];
  };
}
