{ inputs, lib, self, ... }:
{

  flake.lib = {
    makeHomeConf = {
      nixpkgs-channel ? inputs.nixpkgs,
      username ? "pim",
      hostname,
      imports ? [],
      homedir ? "/home/pim",
      system ? "x86_64-linux",
      secondbrain ? false,
      awscontrol ? false,
      desktop ? false,
      swapAltWin ? false,
      ...
      }:
      inputs.home-manager.lib.homeManagerConfiguration {

        modules = [

          inputs.self.modules.homeManager.${username}

          inputs.hm-ricing-mode.homeManagerModules.hm-ricing-mode

          (inputs.import-tree ../../home/_generic-for-contribution)

          {
            home.stateVersion = "24.11";
            home.username = username;
            home.homeDirectory = homedir;
          }
        ] ++ imports;

        pkgs = import nixpkgs-channel {
          inherit system;
          #overlays = [ (import ../overlays) ];
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit inputs system;
          unstable = import inputs.unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };


    makeNixos = {
      hostname,
      channel ? inputs.nixpkgs,
      system ? "x86_64-linux",
      ...
      }:

      channel.lib.nixosSystem {
        modules =
          let
            defaults = { pkgs, ... }: {
              _module.args.inputs = inputs;
              nixpkgs.hostPlatform = system;
              nixpkgs.config.allowUnfree = true;
            };
          in
          [
            defaults

            inputs.self.modules.nixos.${hostname}
          ];
      };
  };
}
