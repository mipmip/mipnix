{ inputs, ... } : {
  flake.modules.nixos.nix-age = { pkgs, ... }: {

    environment.systemPackages = [
      (inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default.override {
        ageBin = "${pkgs.rage}/bin/rage";
      })
    ];

    imports = [
      inputs.agenix.nixosModules.default
    ];

    age.ageBin = "${pkgs.rage}/bin/rage";
  };
}
