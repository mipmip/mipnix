{ inputs, ... } : {
  flake.modules.nixos.dev-vcs-github = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gh
      actionlint
      act # run github workflows locally
    ];
  };
}
