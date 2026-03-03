{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-ai = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      pkgs.unstable.cherry-studio
      pkgs.unstable.jan
      pkgs.unstable.newelle
      pkgs.unstable.sillytavern
      pkgs.unstable.chatbox

    ];
  };
}
