{ inputs, self, ... }:

let
  hostname = "somemac";
in

{
  flake.darwinConfigurations = {
    somemac = inputs.darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        {
          _module.args.inputs = inputs;
          nixpkgs.hostPlatform = "x86_64-darwin";
          nixpkgs.config.allowUnfree = true;
        }
        inputs.self.modules.darwin.${hostname}
      ];
    };
  };

  flake.modules.darwin.somemac = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      git
      home-manager
      docker
      lynis
      neofetch
    ];

    nix.settings.experimental-features = "nix-command flakes";

    # $ darwin-rebuild changelog
    system.stateVersion = 5;
  };

}
