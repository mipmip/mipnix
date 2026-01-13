{ inputs, lib, self, ... }:
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

          (../../home + "/${username}")
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
          #overlays = [ (import ../overlays) ];
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit inputs system;
          inherit (inputs) mipnixvim;
          unstable = import inputs.unstable {
            inherit system;
            #overlays = [ (import ../overlays) ];
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

            # TODO why is this nessecary? shouldn't flake-parts do this
            defaults

            inputs.self.modules.nixos.${hostname}

            ### TODO REMOVE
            (../../hosts + "/${hostname}/configuration.nix")
            # (inputs.import-tree ../../modulesAuto)  # Removed during dendritic migration

          ];
      };
  };
}
