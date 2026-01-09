{ inputs, ... } : {
  flake.modules.nixos.dev-lang-c = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      valgrind-light
    ];
  };
}
