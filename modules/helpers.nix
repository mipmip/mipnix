{ inputs, ... }:
{
  flake.lib = {
    makeHomeConf = {
      nixpkgs-channel ? inputs.nixpkgs,
      username ? "pim",
      hostname,
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
          inputs.hm-ricing-mode.homeManagerModules.hm-ricing-mode
          inputs.walker.homeManagerModules.default
          (../home + "/${username}")
          {
            home.stateVersion = "24.11";
            home.username = username;
            home.homeDirectory = homedir;
            roles.secondbrain.enable = secondbrain;
            roles.awscontrol.enable = awscontrol;
            roles.desktop.enable = desktop;
            desktopConf.gnome.swapAltWin = swapAltWin;
          }
        ];
        pkgs = import nixpkgs-channel {
          inherit system;
          overlays = [ (import ../overlays) ];
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit inputs system;
          inherit (inputs) mipnixvim;
          unstable = import inputs.unstable {
            inherit system;
            overlays = [ (import ../overlays) ];
            config.allowUnfree = true;
          };
        };
      };

    makeNixosConf = {
      nixpkgs-channel ? inputs.nixpkgs,
      hostname,
      system ? "x86_64-linux",
      config ? {},
      extraModules ? [],
      ...
    }:
      nixpkgs-channel.lib.nixosSystem {
        modules =
          let
            defaults = { pkgs, ... }: {
              nixpkgs.overlays = [ (import ../overlays) ];
              _module.args.inputs = inputs;
              _module.args.unstable = import inputs.unstable {
                inherit system;
                overlays = [ (import ../overlays) ];
                config.allowUnfree = true;
              };
            };

            extraPkgs = {
              environment.systemPackages = [
                inputs.agenix.packages."${system}".default
                inputs.myhotkeys.packages."${system}".myhotkeys
                inputs.skull.packages."${system}".skull
              ];
            };
          in
          [
            defaults

            inputs.self.modules.nixos.${hostname}

            (../hosts + "/${hostname}/configuration.nix")
            (inputs.import-tree ../modulesAuto)

            config
            inputs.nix-index-database.nixosModules.nix-index
            inputs.nixos-boot.nixosModules.default
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            { home-manager.useGlobalPkgs = true; }
            extraPkgs
          ]
          ++ extraModules;
      };
  };
}
