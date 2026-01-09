{ inputs, ... } : {
  flake.modules.nixos.dev-lang-nodejs = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nodejs
    ];
  };
}
