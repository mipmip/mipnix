{ inputs, ... }:
{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ (import ../overlays) ];
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };
    };

    _module.args.pkgs-2505 = import inputs.nixpkgs-2505 {
      inherit system;
      overlays = [ (import ../overlays) ];
      config.allowUnfree = true;
    };

    _module.args.pkgs-mama = import inputs.nixpkgs-mama {
      inherit system;
      overlays = [ (import ../overlays) ];
      config.allowUnfree = true;
    };

    _module.args.pkgs-unstable = import inputs.unstable {
      inherit system;
      overlays = [ (import ../overlays) ];
      config.allowUnfree = true;
    };
  };
}
