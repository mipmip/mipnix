{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      fedistar #multicolumn mastodon
      pkgs.unstable.tuba # Mastodon

    ];
  };
}
