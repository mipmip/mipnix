{ inputs, ... } : {

  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      slack


      signal-desktop
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
