{ inputs, ... } : {
  flake.modules.nixos.tui-tmux = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.skull.packages."${pkgs.stdenv.hostPlatform.system}".skull
    ];

  };
}




