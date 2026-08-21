{
  inputs = {


    # GRANNYOS
    nixpkgs-mama.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-mama-moving.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-inkscape13.url = "github:leiserfg/nixpkgs?ref=staging";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable-hyprland.url = "github:NixOS/nixpkgs/nixos-unstable";


    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-boot-grannyos.url = "github:mipmip/nixos-boot-grannyos";


    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware-t2.url = "github:nixos/nixos-hardware";

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "unstable";
    };

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Track the nixvim release branch matching nixpkgs (26.05); `main` follows
    # nixpkgs-unstable and warns about a version mismatch.
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    hm-ricing-mode.url = "github:mipmip/hm-ricing-mode";
    hm-ricing-mode.inputs.nixpkgs.follows = "nixpkgs-2505";

    agenix.url = "github:ryantm/agenix";

    bmc.url = "github:wearetechnative/bmc";
    race.url = "github:wearetechnative/race";

    jsonify-aws-dotfiles.url = "github:mipmip/jsonify-aws-dotfiles";
    myhotkeys.url = "github:mipmip/gnome-hotkeys.cr/0.2.7";

    dirty-repo-scanner.url = "github:mipmip/dirty-repo-scanner";
    jjay.url = "github:speclib/jjay";
    teejay.url = "github:mipmip/teejay";
    specgetty.url = "github:mipmip/specgetty";
    openspec.url = "github:Fission-AI/OpenSpec";
    verynix.url = "github:mipmip/verynix";
    rme.url = "github:mipmip/rme";

    skull.url = "github:mipmip/skull";
    mip.url = "github:mipmip/mip.rs";
    hypr-network-manager.url = "github:mipmip/hypr-network-manager";
    fred.url = "github:linden-project/fred";
    linny-mcp.url = "github:linden-project/linny-mcp-server";
    linny-mcp.inputs.nixpkgs.follows = "nixpkgs";
    huphop.url = "github:mipmip/huphop";

    # Consumed as plain source (its flake only exposes full nixvim configs,
    # not a bare plugin); built with buildVimPlugin in mipvim.
    beans-nvim.url = "github:mipmip/beans.nvim";
    beans-nvim.flake = false;

    aoe.url = "github:njbrake/agent-of-empires";

    voorzetramenshop.url = "git+ssh://git@github.com/mintglasinlood/voorzetramenshop.git";
    voorzetramenshop.inputs.nixpkgs.follows = "nixpkgs";

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

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
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
          pkgs-unstable = import inputs.unstable {
            inherit system;
            config.allowUnfree = true;
          };

          nixvimLib = inputs.nixvim.lib.${system};
          nixvim' = inputs.nixvim.legacyPackages.${system};
          pkgs-nixvim = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          nixvimModule = {
            pkgs = pkgs-nixvim;
            module = {
              imports = [
                (inputs.import-tree ./packages/mipvim/config)
              ];
            };
            extraSpecialArgs = {
              inherit inputs;
              mipColors = import ./lib/colors.nix;
            };
          };

          mipbar-astalPackages = with inputs.ags.packages.${system}; [
            io
            astal4
            hyprland
            network
            battery
            tray
            wireplumber
            bluetooth
          ];

          mipbar-extraPackages = mipbar-astalPackages ++ [
            pkgs-unstable.libadwaita
            pkgs-unstable.libsoup_3
          ];
        in
        {
          packages.mipvim = nixvim'.makeNixvimWithModule nixvimModule;
          checks.mipvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

          devShells.default = pkgs.mkShell {
            buildInputs = [
              (inputs.ags.packages.${system}.default.override {
                extraPackages = mipbar-extraPackages;
              })
            ];
          };

          packages.mipbar = pkgs-unstable.stdenv.mkDerivation {
            name = "mipbar";
            src = ./packages/mipbar;

            nativeBuildInputs = with pkgs-unstable; [
              wrapGAppsHook3
              gobject-introspection
              librsvg # rsvg-convert: rasterize device SVGs to PNG at build time
              inputs.ags.packages.${system}.default
            ];

            buildInputs = mipbar-extraPackages ++ [ pkgs-unstable.gjs ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin
              mkdir -p $out/share
              cp -r * $out/share

              # Rasterize device illustrations to PNG so the runtime never needs
              # an SVG pixbuf loader. deviceImage() loads these from $SRC/assets.
              for svg in $out/share/assets/*.svg; do
                rsvg-convert -w 116 -h 84 "$svg" -o "''${svg%.svg}.png"
              done

              # ASKPASS: the SshKey widget's click-to-load runs `ssh-add` from
              # the detached bar, which has no tty — it needs an askpass to
              # prompt for the passphrase. Inject the path at build time so the
              # widget never depends on SSH_ASKPASS being set in the session.
              ags bundle app.ts $out/bin/mipbar \
                -d "SRC='$out/share'" \
                -d "ASKPASS='${pkgs-unstable.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass'"

              runHook postInstall
            '';
          };

          packages.pimsnel-website = pkgs.runCommand "pimsnel-website" {} ''
            mkdir -p $out
            cp -r ${./packages/pimsnel-website}/* $out/
          '';
        };
    };
}
