{ inputs, ... } : {
  flake.modules.nixos.dev-lang-go = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      go
      gox
      goreleaser

    ];
  };
}
