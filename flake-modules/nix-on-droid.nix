{ inputs, ... }:
{
  flake.nixOnDroidConfigurations.default =
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import inputs.nixpkgs { system = "aarch64-linux"; };
      modules = [ ../hosts/nix-on-droid/configuration.nix ];
    };
}
