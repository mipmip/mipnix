{ inputs, self, ... }:

let
  hostname = "ng";
in

{
  flake.darwinConfigurations = {
    ng = inputs.darwin.lib.darwinSystem {
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

  flake.modules.darwin.ng = { pkgs, ... }: {

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
