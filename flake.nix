{

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # GNOME 49
    nixpkgs-mama.url = "github:NixOS/nixpkgs/nixos-24.11"; # GNOME 47

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-boot-grannyos.url = "github:mipmip/nixos-boot-grannyos";

    nixpkgs-inkscape13.url = "github:leiserfg/nixpkgs?ref=staging";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware-t2.url = "github:nixos/nixos-hardware";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    elephant.url = "github:abenz1267/elephant";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "unstable";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    hm-ricing-mode.url = "github:mipmip/hm-ricing-mode";
    hm-ricing-mode.inputs.nixpkgs.follows = "nixpkgs-2505";
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05";

    agenix.url = "github:ryantm/agenix";

    bmc.url = "github:wearetechnative/bmc";
    race.url = "github:wearetechnative/race";

    jsonify-aws-dotfiles.url = "github:mipmip/jsonify-aws-dotfiles";
    myhotkeys.url = "github:mipmip/gnome-hotkeys.cr/0.2.7";
    shellstuff.url = "github:mipmip/nix-shellstuff";
    dirtygit.url = "github:mipmip/dirtygit";
    skull.url = "github:mipmip/skull";
    mip.url = "github:mipmip/mip.rs";
    openspec.url = "github:mipmip/OpenSpec";
    fred.url = "github:linden-project/fred";

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

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      # Import all flake-parts modules
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      # Define supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Preserve templates
      flake.templates = {
        default = {
          path = ./templates/devshell;
          description = ''
            A minimal flake using flake-parts.
          '';
        };
      };

      # Optional: per-system outputs (formatter, devShells, etc.)
      perSystem = { system, pkgs, ... }:
        let
          # Import unstable nixpkgs for nixvim
          pkgs-unstable = import inputs.unstable {
            inherit system;
            config.allowUnfree = true;
          };

          nixvimLib = inputs.nixvim.lib.${system};
          nixvim' = inputs.nixvim.legacyPackages.${system};
          nixvimModule = {
            pkgs = pkgs-unstable;
            module = {
              imports = [
                (inputs.import-tree ./packages/mipvim/config)
              ];
            };
            extraSpecialArgs = { };
          };
        in
        {
          packages.mipvim = nixvim'.makeNixvimWithModule nixvimModule;
          checks.mipvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
        };
    };
}
