{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-mail = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      kdePackages.kmail
      kdePackages.kdepim-addons
      kdePackages.kaddressbook

      #pkgs.unstable.fastmail-desktop
    ];
  };
}
