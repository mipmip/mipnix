{ inputs, ... } : {
  flake.modules.nixos.desktop-apps-dev = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      vscode
      bruno # UI for testing API's

    ];
  };
}
