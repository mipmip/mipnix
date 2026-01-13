{ inputs, ... }:
{
  flake.nixOnDroidConfigurations.default =
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import inputs.nixpkgs { system = "aarch64-linux"; };
      modules = [ ../hostsOld/fp4-nix-on-droid/configuration.nix ];
    };
}
