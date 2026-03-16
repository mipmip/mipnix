{ inputs, ... }:

{
  flake.modules.nixos.nix-channels =
    let
      initChannel = channel: final:
        import channel { inherit (final) config; system = final.stdenv.hostPlatform.system; };
    in
    {
      nixpkgs.overlays = [

        inputs.self.overlays.apps

        (final: _prev: {
          unstable = initChannel inputs.unstable final;
          unstable-hyprland = initChannel inputs.unstable-hyprland final;
          #upstream-hyprland = initChannel inputs.hyprland final;
        })

      ];
    };

  flake.modules.nixos.nix-channels-mama =
    let
      initChannel = channel: final:
        import channel { inherit (final) config; system = final.stdenv.hostPlatform.system; };
    in
      {
      nixpkgs.overlays = [

        inputs.self.overlays.chipsailing

        (final: _prev: {
          unstable = initChannel inputs.unstable final;
        })

      ];
    };

}
