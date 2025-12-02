{

  inputs = {

    ## MAIN NIXPKGS
    nixpkgs-2211.url = "github:NixOS/nixpkgs/nixos-22.11"; # GNOME 43.2
    #nixpkgs-2305.url = "github:NixOS/nixpkgs/nixos-23.05"; # GNOME 44.2?
    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11"; # GNOME 45.2
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05"; # GNOME 46
    nixpkgs-2411.url = "github:NixOS/nixpkgs/nixos-24.11"; # GNOME 47
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05"; # GNOME 48

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # GNOME 48
    nixpkgs-mama.url = "github:NixOS/nixpkgs/nixos-24.11"; # GNOME 47

    nix-index-database.url = "github:nix-community/nix-index-database"; # <--- Add this
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs"; # <--- Add this

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-boot.url = "github:mipmip/nixos-boot-grannyos";

    nixpkgs-inkscape13.url = "github:leiserfg/nixpkgs?ref=staging";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    #nixos-hardware-t2.url = "github:nixos/nixos-hardware/863e3ca9988f34c370bd660a5efc3e20eb7ad38b";
    nixos-hardware-t2.url = "github:nixos/nixos-hardware";

    # DARWIN
    #nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    #nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    ## HOME MANAGER
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mipnixvim.url = "github:mipmip/mipnixvim";

    hm-ricing-mode.url = "github:mipmip/hm-ricing-mode";
    hm-ricing-mode.inputs.nixpkgs.follows = "nixpkgs-2505";

    ## OTHER
    agenix.url = "github:ryantm/agenix";

    nixified-ai = {
      url = "github:nixified-ai/flake";
    };

    #alacritty-theme.url = "github:alexghr/alacritty-theme.nix";

    bmc.url = "github:wearetechnative/bmc";
    race.url = "github:wearetechnative/race";

    jsonify-aws-dotfiles.url = "github:mipmip/jsonify-aws-dotfiles";
    myhotkeys.url = "github:mipmip/gnome-hotkeys.cr/0.2.7";
    shellstuff.url = "github:mipmip/nix-shellstuff";
    dirtygit.url = "github:mipmip/dirtygit";
    #ghostty.url = "github:ghostty-org/ghostty";
    skull.url = "github:mipmip/skull";
    mip.url = "github:mipmip/mip.rs";

    nixpkgs-pine64.url = "nixpkgs/dfd82985c273aac6eced03625f454b334daae2e8";
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/efbe2c3c5409c868309ae0770852638e623690b5";
      flake = false;
    };
    home-manager-pine64.url = "github:nix-community/home-manager/release-22.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

  };

  outputs =
    inputs@{

      self,

      nixpkgs,
      nixpkgs-mama,
      nixpkgs-2211,
      nixpkgs-2311,
      nixpkgs-2405,
      nixpkgs-2411,
      nixpkgs-2505,
      nixpkgs-inkscape13,
      unstable,

      import-tree,

      #nix-darwin,
      home-manager,
      hm-ricing-mode,
      agenix,

      mipnixvim,

      #alacritty-theme,

      nixos-hardware,
      nixos-hardware-t2,

      nixified-ai,

      nix-index-database,

      nixos-boot,

      jsonify-aws-dotfiles,
      dirtygit,
      bmc,
      race,
      shellstuff,
      skull,
      myhotkeys,
      mip,
      #ghostty,

      nixpkgs-pine64,
      mobile-nixos,
      home-manager-pine64,

      nix-on-droid,
    }:

    let

      importFromChannelForSystem =
        system: channel:
        import channel {
          overlays = [
            (import ./overlays)
            #alacritty-theme.overlays.default
          ];
          inherit system;
          config.permittedInsecurePackages = [
            "libsoup-2.74.3"
          ];

          config.allowUnfree = true;
        };

      makeHomeConf =
        {
          nixpkgs-channel ? nixpkgs,
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
        home-manager.lib.homeManagerConfiguration {
          modules = [

            hm-ricing-mode.homeManagerModules.hm-ricing-mode

            (import ./home/${username})
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
          pkgs = importFromChannelForSystem system nixpkgs-channel;
          extraSpecialArgs = {
            inputs = inputs;
            unstable = importFromChannelForSystem system unstable;
            #swapAltWin = swapAltWin;
          };
        };

      makeNixosConf =
        {
          nixpkgs-channel ? nixpkgs,
          hostname,
          system ? "x86_64-linux",
          config ? { },
          extraModules ? [ ],
          ...
        }:

        nixpkgs-channel.lib.nixosSystem {
          modules =
            let
              defaults =
                { pkgs, ... }:
                {
                  nixpkgs.overlays = [ (import ./overlays) ];
                  _module.args.inputs = inputs;
                  _module.args.unstable = importFromChannelForSystem system unstable;
                  _module.args.pkgs-2211 = importFromChannelForSystem system nixpkgs-2211;
                };

              extraPkgs = {
                environment.systemPackages = [
                  agenix.packages."${system}".default
                  myhotkeys.packages."${system}".myhotkeys
                  skull.packages."${system}".skull
                  mipnixvim.packages."${system}".default
                ];

              };

            in
            [
              defaults
              (./hosts + "/${hostname}/configuration.nix")

              (inputs.import-tree ./modulesAuto)
              config

              nix-index-database.nixosModules.nix-index
              nixos-boot.nixosModules.default
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
              }

              extraPkgs

            ]
            ++ extraModules;
        };

    in
    rec {

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;

      homeConfigurations."pim@hurry" = makeHomeConf {
        hostname = "hurry";
        system = "aarch64-linux";
      };

      homeConfigurations."pim@arcana-one" = makeHomeConf {
        hostname = "arcana-one";
      };

      #      homeConfigurations."pim@somemac" = makeHomeConf {
      #        hostname = "MacBook-Pro-van-pim";
      #        system = "x86_64-darwin";
      #        homedir = "/Users/pim";
      #      };

      homeConfigurations."pim@harry" = makeHomeConf {
        hostname = "harry";
        system = "aarch64-linux";
      };

      homeConfigurations."pim@tn-nixhost" = makeHomeConf {
        hostname = "tn-nixhost";
        awscontrol = true;
      };

      homeConfigurations."pim@rodin" = makeHomeConf {
        hostname = "rodin";
        secondbrain = true;
        awscontrol = true;
        desktop = true;
        swapAltWin = true;
      };

      homeConfigurations."pim@lego1" = makeHomeConf {
        hostname = "lego1";
        secondbrain = true;
        awscontrol = true;
        desktop = true;
        swapAltWin = true;
      };

      homeConfigurations."pim@lego2" = makeHomeConf {
        hostname = "lego1";
        secondbrain = true;
        awscontrol = true;
        desktop = true;
      };

      homeConfigurations."pim@ojs" = makeHomeConf {
        hostname = "ojs";
        desktop = true;
      };

      homeConfigurations."annemarie@passieflora" = makeHomeConf {
        hostname = "passieflora";
        desktop = true;
        username = "annemarie";
        homedir = "/home/annemarie";
      };

      homeConfigurations."pim@passieflora" = makeHomeConf {
        hostname = "passieflora";
        desktop = true;
      };

      nixosConfigurations.rodin = makeNixosConf rec {
        hostname = "rodin";
        config = {
          nixos.ai.enable = true;
          nixos.aiLocal.enable = false;
          nixos.dev.enable = true;
          nixos.desktop.enable = true;
          nixos.desktopHyprland.enable = true;
          nixos.nixUtils.enable = true;
          nixos.nixRemoteBuilds.enable = false;
          nixos.trusted.enable = true;
          nixos.tex.enable = true;
          nixos.hardware.keychron.enable = true;
        };
      };

      nixosConfigurations.passieflora = makeNixosConf {
        hostname = "passieflora";
        extraModules = [
          ./hosts/passieflora/nix/substituter.nix
          nixos-hardware-t2.nixosModules.apple-t2
        ];
      };

      nixosConfigurations.lego1 = makeNixosConf rec {
        hostname = "lego1";
        system = "x86_64-linux";
        config = {
          imports = [
            nixos-hardware.nixosModules.framework-12th-gen-intel
          ];
          environment.systemPackages = [
            myhotkeys.packages."${system}".myhotkeys
          ];
          nixos.ai.enable = true;
          nixos.dev.enable = true;
          nixos.desktop.enable = true;
          nixos.desktopHyprland.enable = true;
          nixos.nixUtils.enable = true;
          nixos.nixRemoteBuilds.enable = false;
          nixos.tex.enable = true;
          nixos.trusted.enable = true;
          nixos.hardware.keychron.enable = true;
        };
      };

      nixosConfigurations.lego2 = makeNixosConf rec {
        hostname = "lego2";
        system = "x86_64-linux";
        config = {
          imports = [
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
          environment.systemPackages = [
            myhotkeys.packages."${system}".myhotkeys
          ];
          nixos.ai.enable = true;
          nixos.dev.enable = true;
          nixos.desktop.enable = true;
          nixos.virtualization.enable = true;
          nixos.bambulabs.enable = true;
          nixos.desktopHyprland.enable = true;
          nixos.nixUtils.enable = true;
          nixos.nixpkgsDev.enable = true;
          nixos.nixRemoteBuilds.enable = false;
          nixos.tex.enable = true;
          nixos.trusted.enable = true;
          nixos.hardware.keychron.enable = false;
        };
      };

      nixosConfigurations.hurry = makeNixosConf {
        hostname = "hurry";
        system = "aarch64-linux";
      };

      nixosConfigurations.harry = makeNixosConf {
        hostname = "harry";
        system = "aarch64-linux";
      };

      nixosConfigurations.ojs = makeNixosConf {
        hostname = "ojs";
      };

      nixosConfigurations.gnome-45 = makeNixosConf {
        hostname = "gnome-45";
        extraModules = [
          {
            nixpkgs.config.pkgs = import nixpkgs-2311 { system = "x86_64-linux"; };
          }
        ];
      };

      nixosConfigurations.grannyos = makeNixosConf {
        hostname = "grannyos";
        extraModules = [
          {
            nixpkgs.config.pkgs = import nixpkgs-2311 { system = "x86_64-linux"; };
          }
        ];
      };

      nixosConfigurations.billquick = makeNixosConf {
        hostname = "billquick";
      };

      nixosConfigurations.pinephone = (
        nixpkgs-pine64.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            home-manager = home-manager-pine64;
          };
          modules = [
            (import "${mobile-nixos}/lib/configuration.nix" {
              device = "pine64-pinephone";
            })
            ./hosts/pesto/default.nix
          ];
        }
      );
      pinephone-img = nixosConfigurations.pinephone.config.mobile.outputs.u-boot.disk-image;

      #      darwinConfigurations."MacBook-Pro-van-pim" = nix-darwin.lib.darwinSystem {
      #      	modules = [
      #      	  ./hosts/somemac/configuration.nix
      #        ];
      #      };

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./hosts/nix-on-droid/configuration.nix ];
      };

      templates = {
        default = {
          path = ./templates/devshell;
          description = ''
            A minimal flake using flake-parts.
          '';
        };
      };

    };
}
