{ inputs, ... } : {

  flake.modules.nixos.desktop-apps-communication = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      slack


      signal-desktop
      #pkgs.unstable.flare-signal

      #zoom-us
      rustdesk
      fractal

      #msmtp
      #teams
      teams-for-linux
      #unstable.srain #IRC

      discord
      vesktop

      himalaya

      # WhatsApp client. WebKit sandbox workaround applied via the `apps`
      # overlay (modules/nix/overlays/apps.nix).
      karere
    ];
  };
}
