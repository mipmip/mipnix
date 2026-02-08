{ inputs, ... }:

{
  flake.modules.nixos.nix-channels =
    let
      initChannel = channel: final:
        import channel { inherit (final) config system; };
    in
    {
      nixpkgs.overlays = [

        inputs.self.overlays.apps

        (final: _prev: {
          unstable = initChannel inputs.unstable final;

          # TODO use this the other way around: makeNixos { channel = nixpkgs-mama; }
          # nixmama = initChannel inputs.nixpkgs-mama final;
        })

      ];
    };

  flake.modules.nixos.nix-channels-mama =
    let
      initChannel = channel: final:
        import channel { inherit (final) config system; };
    in
      {
      nixpkgs.overlays = [

        inputs.self.overlays.chipsailing

        (final: _prev: {
          unstable = initChannel inputs.unstable final;

          # TODO use this the other way around: makeNixos { channel = nixpkgs-mama; }
          # nixmama = initChannel inputs.nixpkgs-mama final;
        })

      ];
    };

}
