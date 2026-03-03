{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-mail = { config, pkgs, ... }: {
    programs.kde-pim.enable = true;
    programs.kde-pim.kmail = true;
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
