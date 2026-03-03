{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-mail = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      kdePackages.kmail
      kdePackages.kdepim-addons
      kdePackages.kaddressbook
      kdePackages.akonadi
      kdePackages.akonadiconsole
      kdePackages.akonadi-search

      #pkgs.unstable.fastmail-desktop
    ];
  };
}
