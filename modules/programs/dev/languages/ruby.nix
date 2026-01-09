{ inputs, ... } : {
  flake.modules.nixos.dev-lang-ruby = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
    ];
  };
}
