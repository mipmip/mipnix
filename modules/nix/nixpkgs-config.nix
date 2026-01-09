{ inputs, ... } : {
  flake.modules.nixos.nix-nixpkgs-config = { pkgs, ... }: {
    nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        mipmip_pkg = import (../../pkgs) {
          inherit pkgs;
        };
      };
    };
  };
}
