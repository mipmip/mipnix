{ inputs, ... }:
{
  flake.modules.homeManager.pim-lobby = { pkgs, ... }: {
    home.packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.lobby
    ];
  };
}
