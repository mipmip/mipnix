{ inputs, ... } : {
  flake.modules.nixos.nix-nixpkgs-dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nixpkgs-review
      nix-output-monitor
      glow
      delta
    ];
  };
}
