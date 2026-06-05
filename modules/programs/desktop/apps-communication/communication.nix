{ inputs, ... } : {

  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.slack


      pkgs.signal-desktop
      #pkgs.unstable.flare-signal

      #zoom-us
      #rustdesk
      fractal

      #msmtp
      #teams
      #unstable.srain #IRC

      discord
      vesktop

      # TODO Remove
      himalaya
      karere
    ];
  };
}
