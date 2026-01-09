{ inputs, ... } : {
  flake.modules.nixos.dev-lang-rust = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      rust-analyzer
      cargo
      rustc
      rustfmt
    ];
  };
}
