{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-browsers = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.firefox
      librewolf
    ];

  };
}
