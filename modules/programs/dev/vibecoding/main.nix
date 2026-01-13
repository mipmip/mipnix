{ inputs, ... } : {
  flake.modules.nixos.vibecoding-main = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.claude-code
      pkgs.unstable.beads

      inputs.openspec.packages."${pkgs.stdenv.hostPlatform.system}".default

      ## util programs used by agents
      tree
    ];
  };
}
