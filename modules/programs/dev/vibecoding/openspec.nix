{ inputs, ... } : {

  flake.modules.nixos.vibecoding-main = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      inputs.openspec.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
