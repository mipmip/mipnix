{ inputs, lib, self, ... }:
{

  flake.lib = {
    # Nebula nodes as "<name> <ip>" lines for the tmux SSH host picker. Derived
    # from the single-source flake.nebulaNodes registry (sorted by name); reads only
    # literal strings, so no nixosConfigurations eval / inputs.self recursion.
    nebulaHosts = lib.mapAttrsToList (name: ip: "${name} ${ip}") self.nebulaNodes;

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

          #          inputs.self.modules.homeManager.${username}
          inputs.self.modules.homeManager.pim-homeWith-options

          inputs.hm-ricing-mode.homeManagerModules.hm-ricing-mode

          (inputs.import-tree ../_generic-for-contribution)

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
          unstable-hyprland = import inputs.unstable-hyprland {
            inherit system;
            config.allowUnfree = true;
          };
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
              nixpkgs.config.permittedInsecurePackages = [
                "electron-39.8.10"
              ];
            };
          in
          [
            defaults

            inputs.self.modules.nixos.${hostname}
          ];
      };

    # Build a single deploy-rs node for a host. The node name matches the
    # nixosConfigurations name (`hostname`); `ip` is the SSH target address.
    makeDeployNode = {
      hostname,
      ip,
      system ? "x86_64-linux",
      sshUser ? "pim",
      autoRollback ? true,
      magicRollback ? true,
      ...
      }:
      {
        nodes.${hostname} = {
          hostname = ip;
          inherit sshUser autoRollback magicRollback;

          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.${system}.activate.nixos
              self.nixosConfigurations.${hostname};
          };
        };
      };
  };
}
