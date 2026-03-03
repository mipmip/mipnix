{ inputs, ... } : {

  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.slack

      pkgs.unstable.wasistlos

      pkgs.unstable.signal-desktop
      pkgs.unstable.flare-signal

      zoom-us
      rustdesk

      #msmtp
      #teams
      #unstable.srain #IRC

      discord
      vesktop

      # TODO Remove
      pkgs.unstable.himalaya
    ];
  };
}
