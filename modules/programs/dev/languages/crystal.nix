{ inputs, ... } : {
  flake.modules.nixos.dev-lang-crystal = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      crystal
      shards
      crystal2nix
      #mipmip_pkg.crelease replace is needed
    ];
  };
}
